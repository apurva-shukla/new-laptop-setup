#!/usr/bin/env bash

set -euo pipefail

# Focus next space. If skip-empty mode is on, only visit occupied spaces.
# Wraps around at the end.

if ! command -v yabai >/dev/null 2>&1; then
    exit 0
fi

SKIP_FILE="/tmp/skhd_skip_empty_spaces"

# If skip mode is off, just go to next space directly
if [ ! -f "$SKIP_FILE" ]; then
    yabai -m space --focus next 2>/dev/null || yabai -m space --focus first 2>/dev/null
    exit 0
fi

# Skip-empty mode: find next occupied space
command -v jq >/dev/null 2>&1 || exit 0

current="$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index // empty' 2>/dev/null)" || exit 0
[[ "$current" =~ ^[0-9]+$ ]] || exit 0

# Get list of occupied spaces (spaces with visible windows)
occupied="$(yabai -m query --windows 2>/dev/null | jq -r '
  [.[] | select(."is-minimized" == false and ."is-hidden" == false) | .space] | unique | sort | .[]
' 2>/dev/null)" || exit 0

[ -n "$occupied" ] || exit 0

# Find next occupied space after current
next=""
for s in $occupied; do
    if [ "$s" -gt "$current" ]; then
        next=$s
        break
    fi
done

# Wrap around if no next found
if [ -z "$next" ]; then
    for s in $occupied; do
        if [ "$s" -ne "$current" ]; then
            next=$s
            break
        fi
    done
fi

# Focus the space if found
if [ -n "$next" ]; then
    yabai -m space --focus "$next"
fi
