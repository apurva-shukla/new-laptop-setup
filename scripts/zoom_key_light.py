#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request


DEFAULT_BRIGHTNESS = 55
DEFAULT_TEMPERATURE = 213
DEFAULT_HOME_PREFIX = "192.168.1."


def run_quiet(args, timeout=2):
    try:
        return subprocess.run(
            args,
            check=False,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None


def local_ip(interface):
    result = run_quiet(["ipconfig", "getifaddr", interface])
    if result and result.returncode == 0:
        return result.stdout.strip()
    return ""


def zoom_meeting_active():
    result = run_quiet(["pgrep", "-x", "CptHost"])
    if result and result.returncode == 0:
        return True

    script = r'''
tell application "System Events"
  if not (exists process "zoom.us") then return "false"
  tell process "zoom.us"
    set windowNames to name of windows
    repeat with windowName in windowNames
      set w to windowName as text
      if w contains "Zoom Meeting" or w contains "Meeting" then return "true"
    end repeat
  end tell
end tell
return "false"
'''
    result = run_quiet(["osascript", "-e", script], timeout=3)
    return bool(result and result.returncode == 0 and result.stdout.strip() == "true")


def key_light_payload(on, brightness, temperature):
    light = {"on": 1 if on else 0}
    if on:
        light["brightness"] = brightness
        light["temperature"] = temperature
    return {"numberOfLights": 1, "lights": [light]}


def set_key_light(base_url, on, brightness, temperature):
    url = base_url.rstrip("/") + "/elgato/lights"
    data = json.dumps(key_light_payload(on, brightness, temperature)).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=data,
        method="PUT",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(request, timeout=3) as response:
        response.read()


def key_light_reachable(base_url):
    try:
        with urllib.request.urlopen(base_url.rstrip("/") + "/elgato/lights", timeout=2) as response:
            return response.status == 200
    except (OSError, urllib.error.URLError):
        return False


def log(message):
    print(time.strftime("%Y-%m-%d %H:%M:%S"), message, flush=True)


def main():
    parser = argparse.ArgumentParser(description="Turn an Elgato Key Light on during Zoom meetings.")
    parser.add_argument("--key-light-url", default=os.environ.get("ELGATO_KEY_LIGHT_URL"))
    parser.add_argument("--brightness", type=int, default=int(os.environ.get("ELGATO_BRIGHTNESS", DEFAULT_BRIGHTNESS)))
    parser.add_argument("--temperature", type=int, default=int(os.environ.get("ELGATO_TEMPERATURE", DEFAULT_TEMPERATURE)))
    parser.add_argument("--interval", type=float, default=float(os.environ.get("ZOOM_KEY_LIGHT_INTERVAL", 3)))
    parser.add_argument("--home-prefix", default=os.environ.get("ELGATO_HOME_NETWORK_PREFIX", DEFAULT_HOME_PREFIX))
    parser.add_argument("--interface", default=os.environ.get("ELGATO_HOME_INTERFACE", "en0"))
    parser.add_argument("--turn-off-after", action="store_true", default=os.environ.get("ELGATO_TURN_OFF_AFTER") == "1")
    parser.add_argument("--once", action="store_true")
    args = parser.parse_args()

    if not args.key_light_url:
        log("Set ELGATO_KEY_LIGHT_URL, for example: http://192.168.1.123:9123")
        return 2

    last_active = None
    last_network_home = None
    last_reachable = None
    while True:
        current_ip = local_ip(args.interface)
        network_home = current_ip.startswith(args.home_prefix)
        if network_home != last_network_home:
            if network_home:
                log(f"Home network detected on {args.interface}: {current_ip}")
            else:
                log(f"Not on home network; current {args.interface} IP is {current_ip or 'unavailable'}")
            last_network_home = network_home

        if not network_home:
            last_active = None
            if args.once:
                return 2
            time.sleep(args.interval)
            continue

        if not key_light_reachable(args.key_light_url):
            if last_reachable is not False:
                log(f"Could not reach Key Light at {args.key_light_url}; retrying")
            last_reachable = False
            if args.once:
                return 2
            time.sleep(args.interval)
            continue
        if last_reachable is False:
            log(f"Key Light reachable at {args.key_light_url}")
        last_reachable = True

        active = zoom_meeting_active()
        if active != last_active:
            try:
                if active:
                    set_key_light(args.key_light_url, True, args.brightness, args.temperature)
                    log("Zoom meeting detected; Key Light on")
                elif args.turn_off_after:
                    set_key_light(args.key_light_url, False, args.brightness, args.temperature)
                    log("Zoom meeting ended; Key Light off")
                else:
                    log("Zoom meeting inactive; leaving Key Light as-is")
                last_active = active
            except (OSError, urllib.error.URLError) as error:
                log(f"Key Light update failed: {error}")

        if args.once:
            return 0
        time.sleep(args.interval)


if __name__ == "__main__":
    sys.exit(main())
