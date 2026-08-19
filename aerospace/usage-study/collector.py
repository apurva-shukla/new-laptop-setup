#!/usr/bin/python3
"""Collect a five-day, privacy-preserving AeroSpace usage trace.

The collector intentionally records no window titles, URLs, typed text,
screenshots, clipboard contents, or document contents.
"""

import fcntl
import json
import os
import selectors
import signal
import subprocess
import sys
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path


AEROSPACE = "/opt/homebrew/bin/aerospace"
DATA_DIR = Path.home() / "Library" / "Application Support" / "AeroSpace Usage Study"
EVENTS_PATH = DATA_DIR / "events.jsonl"
METADATA_PATH = DATA_DIR / "study.json"
LOCK_PATH = DATA_DIR / "collector.lock"
DURATION = timedelta(days=5)
SNAPSHOT_INTERVAL_SECONDS = 15 * 60

WINDOW_FORMAT = "%{window-id}%{app-bundle-id}%{app-name}%{workspace}%{monitor-id}%{monitor-name}"
WORKSPACE_FORMAT = "%{workspace}%{monitor-id}%{monitor-name}%{workspace-is-visible}%{workspace-is-focused}%{workspace-root-container-layout}"

stop_requested = False


def utc_now():
    return datetime.now(timezone.utc)


def iso8601(value):
    return value.isoformat(timespec="milliseconds").replace("+00:00", "Z")


def parse_iso8601(value):
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


def request_stop(_signum, _frame):
    global stop_requested
    stop_requested = True


def append_event(handle, event_type, **payload):
    row = {"timestamp": iso8601(utc_now()), "type": event_type}
    row.update(payload)
    json.dump(row, handle, separators=(",", ":"), sort_keys=True)
    handle.write("\n")
    handle.flush()


def load_or_create_metadata():
    if METADATA_PATH.exists():
        with METADATA_PATH.open("r", encoding="utf-8") as handle:
            return json.load(handle)

    started_at = utc_now()
    metadata = {
        "schemaVersion": 1,
        "startedAt": iso8601(started_at),
        "endsAt": iso8601(started_at + DURATION),
        "durationDays": 5,
        "aerospacePath": AEROSPACE,
        "privacy": {
            "records": [
                "timestamps",
                "application bundle identifiers and names",
                "AeroSpace window identifiers",
                "workspace and monitor identifiers",
                "focus, workspace, monitor, and binding events",
                "workspace layout and visibility",
            ],
            "neverRecords": [
                "window titles",
                "URLs",
                "typed text or keystrokes outside AeroSpace bindings",
                "screenshots",
                "clipboard contents",
                "document or message contents",
            ],
        },
    }
    temporary_path = METADATA_PATH.with_suffix(".json.tmp")
    with temporary_path.open("w", encoding="utf-8") as handle:
        json.dump(metadata, handle, indent=2, sort_keys=True)
        handle.write("\n")
    temporary_path.replace(METADATA_PATH)
    return metadata


def aerospace_json(*arguments):
    completed = subprocess.run(
        [AEROSPACE, *arguments],
        check=True,
        capture_output=True,
        text=True,
        timeout=10,
    )
    return json.loads(completed.stdout)


def capture_snapshot(handle):
    try:
        windows = aerospace_json(
            "list-windows", "--all", "--json", "--format", WINDOW_FORMAT
        )
        workspaces = aerospace_json(
            "list-workspaces", "--all", "--json", "--format", WORKSPACE_FORMAT
        )
        append_event(handle, "state-snapshot", windows=windows, workspaces=workspaces)
    except (OSError, subprocess.SubprocessError, json.JSONDecodeError) as error:
        append_event(handle, "snapshot-error", errorType=type(error).__name__)


def terminate(process):
    if process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=3)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=3)


def main():
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    lock_handle = LOCK_PATH.open("a+", encoding="utf-8")
    try:
        fcntl.flock(lock_handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return 0

    metadata = load_or_create_metadata()
    ends_at = parse_iso8601(metadata["endsAt"])
    if utc_now() >= ends_at:
        return 0

    if not os.path.isfile(AEROSPACE):
        return 1

    signal.signal(signal.SIGTERM, request_stop)
    signal.signal(signal.SIGINT, request_stop)

    with EVENTS_PATH.open("a", encoding="utf-8", buffering=1) as events_handle:
        append_event(
            events_handle,
            "collector-started",
            studyStartedAt=metadata["startedAt"],
            studyEndsAt=metadata["endsAt"],
        )
        capture_snapshot(events_handle)
        next_snapshot_at = time.monotonic() + SNAPSHOT_INTERVAL_SECONDS

        try:
            process = subprocess.Popen(
                [AEROSPACE, "subscribe", "--all", "--no-send-initial"],
                stdout=subprocess.PIPE,
                text=True,
                bufsize=1,
            )
        except OSError as error:
            append_event(events_handle, "subscriber-start-error", errorType=type(error).__name__)
            return 1

        selector = selectors.DefaultSelector()
        selector.register(process.stdout, selectors.EVENT_READ)

        try:
            while not stop_requested and utc_now() < ends_at:
                if process.poll() is not None:
                    append_event(
                        events_handle,
                        "subscriber-exited",
                        returnCode=process.returncode,
                    )
                    return 1

                now_monotonic = time.monotonic()
                if now_monotonic >= next_snapshot_at:
                    capture_snapshot(events_handle)
                    next_snapshot_at = now_monotonic + SNAPSHOT_INTERVAL_SECONDS

                remaining = max(0.0, (ends_at - utc_now()).total_seconds())
                timeout = min(1.0, remaining)
                for key, _mask in selector.select(timeout=timeout):
                    line = key.fileobj.readline()
                    if not line:
                        continue
                    try:
                        event = json.loads(line)
                    except json.JSONDecodeError:
                        append_event(events_handle, "subscriber-parse-error")
                        continue
                    append_event(events_handle, "aerospace-event", event=event)
        finally:
            selector.close()
            terminate(process)

        if utc_now() >= ends_at:
            capture_snapshot(events_handle)
            append_event(events_handle, "study-completed", studyEndsAt=metadata["endsAt"])
        else:
            append_event(events_handle, "collector-stopped")
    return 0


if __name__ == "__main__":
    sys.exit(main())
