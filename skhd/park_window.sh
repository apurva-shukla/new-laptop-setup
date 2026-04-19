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
front_app="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null || true)"

window_id=""
window_space=""
window_app=""
is_floating=""

if [ -n "$front_app" ] && [ -n "$visible_space" ]; then
  window_id="$(
    jq -r --arg app "$front_app" --argjson space "$visible_space" '
      [
        .[]
        | select(
            .space == $space
            and .app == $app
            and ."is-visible" == true
            and ."is-hidden" == false
            and ."is-minimized" == false
          )
      ]
      | sort_by(."has-focus")
      | last
      | .id // empty
    ' "$windows_file"
  )"
fi

if [ -n "$window_id" ]; then
  window_space="$visible_space"
  window_app="$front_app"
  is_floating="$(
    jq -r --argjson target "$window_id" '.[] | select(.id == $target) | ."is-floating"' "$windows_file" | head -n1
  )"
else
  window_id="$(jq -r '.[] | select(."has-focus" == true) | .id' "$windows_file" | head -n1)"
  window_space="$(jq -r '.[] | select(."has-focus" == true) | .space' "$windows_file" | head -n1)"
  window_app="$(jq -r '.[] | select(."has-focus" == true) | .app' "$windows_file" | head -n1)"
  is_floating="$(jq -r '.[] | select(."has-focus" == true) | ."is-floating"' "$windows_file" | head -n1)"
fi

[ -n "$window_id" ] || {
  rm -f "$windows_file"
  exit 0
}

debug_log "start id=$window_id app=$window_app space=$window_space floating=$is_floating"

fallback_id=""

recent_file="$(mktemp)"
if yabai -m query --windows --window recent > "$recent_file" 2>/dev/null; then
  recent_id="$(jq -r '.id // empty' "$recent_file")"
  recent_space="$(jq -r '.space // empty' "$recent_file")"
  recent_floating="$(jq -r '."is-floating" // false' "$recent_file")"
  recent_hidden="$(jq -r '."is-hidden" // false' "$recent_file")"
  recent_minimized="$(jq -r '."is-minimized" // false' "$recent_file")"
  if [ -n "$recent_id" ] \
    && [ "$recent_id" != "$window_id" ] \
    && [ "$recent_space" = "$window_space" ] \
    && [ "$recent_floating" = "false" ] \
    && [ "$recent_hidden" = "false" ] \
    && [ "$recent_minimized" = "false" ]; then
    fallback_id="$recent_id"
  fi
fi
rm -f "$recent_file"

if [ -z "$fallback_id" ]; then
  fallback_id="$(
    jq -r --argjson target "$window_id" --argjson space "$window_space" '
          map(select(
            .id != $target
            and .space == $space
            and ."is-hidden" == false
            and ."is-minimized" == false
            and ."is-floating" == false
          ))
          | first
          | .id // empty
        ' "$windows_file"
  )"
fi

if [ -z "$fallback_id" ]; then
  fallback_id="$(
    jq -r --argjson target "$window_id" --argjson space "$window_space" '
          map(select(
            .id != $target
            and .space == $space
            and ."is-hidden" == false
            and ."is-minimized" == false
          ))
          | first
          | .id // empty
        ' "$windows_file"
  )"
fi

debug_log "fallback id=${fallback_id:-none}"

same_space_ids="$(
  jq -r --argjson space "$window_space" '
    .[]
    | select(
        .space == $space
        and ."is-hidden" == false
        and ."is-minimized" == false
        and ."is-floating" == false
      )
    | .id
  ' "$windows_file"
)"

if [ -n "$same_space_ids" ]; then
  printf '%s\n' "$same_space_ids" | while IFS= read -r id; do
    [ -n "$id" ] || continue
    yabai -m window "$id" --sub-layer normal >/dev/null 2>&1 || true
  done
fi

if [ "$is_floating" != "true" ]; then
  yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 4:4:1:1:2:2
fi

yabai -m window "$window_id" --sub-layer normal >/dev/null 2>&1 || true
yabai -m window "$window_id" --lower >/dev/null 2>&1 || true

if [ -n "$fallback_id" ]; then
  yabai -m window --focus "$fallback_id" >/dev/null 2>&1 || true
fi

focused_after="$(
  yabai -m query --windows 2>/dev/null \
    | jq -r '[.[] | select(."has-focus" == true) | .id, .app, .space, ."is-floating", ."sub-layer"] | @tsv' 2>/dev/null || true
)"
rm -f "$windows_file"
debug_log "end focused=${focused_after:-unknown}"

log_action "Float" "Parked in background"
notify "Float" "Parked in background"
