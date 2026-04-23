#!/usr/bin/env bash

set -euo pipefail

# Focus previous space. If skip-empty mode is on, only visit occupied spaces.
# Wraps around at the beginning.

if ! command -v yabai >/dev/null 2>&1; then
    exit 0
fi

SKIP_FILE="/tmp/skhd_skip_empty_spaces"
SKHD_LOG="${SKHD_LOG:-$HOME/.local/share/skhd/usage.log}"
_log() {
    (
        mkdir -p "$(dirname "$SKHD_LOG")"
        printf '%s\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >> "$SKHD_LOG"
    ) >/dev/null 2>&1 &
}

# If skip mode is off, just go to prev space directly
if [ ! -f "$SKIP_FILE" ]; then
    yabai -m space --focus prev 2>/dev/null || yabai -m space --focus last 2>/dev/null
    _log "Nav" "← Prev space"
    exit 0
fi

# Skip-empty mode: find previous occupied space
command -v jq >/dev/null 2>&1 || exit 0

current="$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index // empty' 2>/dev/null)" || exit 0
[[ "$current" =~ ^[0-9]+$ ]] || exit 0

prev="$(
    yabai -m query --windows 2>/dev/null | jq -r --argjson current "$current" '
      [
        .[]
        | select(."is-minimized" == false and ."is-hidden" == false)
        | .space
      ]
      | unique
      | sort
      | reverse as $occupied
      | (
          ($occupied | map(select(. < $current)) | first)
          // ($occupied | map(select(. != $current)) | first)
          // empty
        )
    ' 2>/dev/null
)" || exit 0

# Focus the space if found
if [ -n "$prev" ]; then
    yabai -m space --focus "$prev"
    _log "Nav" "← Prev occupied (space $prev)"
fi
