#!/usr/bin/env bash

set -euo pipefail

SKHD_LOG="${SKHD_LOG:-$HOME/.local/share/skhd/usage.log}"
DEBUG_LOG="${SKHD_PARK_DEBUG_LOG:-/tmp/skhd-park-window.log}"

log_action() {
  mkdir -p "$(dirname "$SKHD_LOG")"
  printf '%s\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >> "$SKHD_LOG"
}

debug_log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$DEBUG_LOG"
}

notify() {
  local title="$1"
  local body="$2"
  osascript -e "display notification \"$body\" with title \"$title\"" >/dev/null 2>&1 &
}

command -v yabai >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

windows_file="$(mktemp)"
yabai -m query --windows > "$windows_file" 2>/dev/null || {
  rm -f "$windows_file"
  exit 0
}

visible_space="$(yabai -m query --spaces 2>/dev/null | jq -r '.[] | select(."is-visible" == true) | .index' | head -n1)"
window_id=""
window_app=""
is_floating=""

window_id="$(
  jq -r --argjson space "${visible_space:-0}" '
    [
      .[]
      | select(
          .space == $space
          and ."is-visible" == true
          and ."is-hidden" == false
          and ."is-minimized" == false
          and ."is-floating" == true
        )
    ]
    | last
    | .id // empty
  ' "$windows_file"
)"
window_app="$(
  jq -r --argjson target "${window_id:-0}" '.[] | select(.id == $target) | .app' "$windows_file" | head -n1
)"
is_floating="$(
  jq -r --argjson target "${window_id:-0}" '.[] | select(.id == $target) | ."is-floating"' "$windows_file" | head -n1
)"
rm -f "$windows_file"

[ -n "$window_id" ] || {
  exit 0
}

[ "$is_floating" = "true" ] || exit 0

debug_log "raise start id=$window_id app=$window_app"
yabai -m window --focus "$window_id" >/dev/null 2>&1 || true
yabai -m window "$window_id" --toggle float >/dev/null 2>&1 || true
yabai -m window "$window_id" --sub-layer normal >/dev/null 2>&1 || true
yabai -m window "$window_id" --raise >/dev/null 2>&1 || true
yabai -m window --focus "$window_id" >/dev/null 2>&1 || true
debug_log "raise done id=$window_id"

log_action "Float" "Raised to front"
notify "Float" "Raised to front"
