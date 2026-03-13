#!/usr/bin/env bash

set -euo pipefail

PATH="/opt/homebrew/bin:/opt/homebrew/opt/sketchybar/bin:/usr/bin:/bin:/usr/sbin:/sbin"
LOG_FILE="/tmp/sketchybar_watchdog.log"
SKETCHYBAR_BIN="${SKETCHYBAR_BIN:-$(command -v sketchybar || true)}"

capture_sample() {
  local name="$1"
  local pid="$2"
  local sample_file="/tmp/${name}_$(date '+%Y%m%d_%H%M%S').sample.txt"

  if [ -n "$pid" ] && command -v sample >/dev/null 2>&1; then
    sample "$pid" 1 >"$sample_file" 2>&1 || true
    log "captured sample for ${name} pid=${pid} at ${sample_file}"
  fi
}

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >>"$LOG_FILE"
}

if [ -z "$SKETCHYBAR_BIN" ]; then
  exit 0
fi

TIMEOUT_BIN=""
if command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_BIN="gtimeout"
elif command -v timeout >/dev/null 2>&1; then
  TIMEOUT_BIN="timeout"
else
  log "timeout binary not available; skipping health check"
  exit 0
fi

if "$TIMEOUT_BIN" 5 "$SKETCHYBAR_BIN" --query bar >/dev/null 2>&1; then
  exit 0
fi

log "health check failed; restarting sketchybar"
capture_sample "sketchybar" "$(pgrep -x sketchybar | head -n 1 || true)"
capture_sample "sketchybar_lua" "$(pgrep -f 'lua .*sketchybarrc' | head -n 1 || true)"
launchctl kickstart -k "gui/${UID}/homebrew.mxcl.sketchybar" >/dev/null 2>&1 || \
  brew services restart sketchybar >/dev/null 2>&1 || true
