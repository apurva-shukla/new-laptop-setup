#!/bin/bash

# Focus next space that has non-minimized, non-hidden windows
# Wraps around to first occupied space if at end

current=$(yabai -m query --spaces --space | jq '.index')

# Get list of occupied spaces (spaces with visible windows)
occupied=$(yabai -m query --windows | jq -r '
  [.[] | select(."is-minimized" == false and ."is-hidden" == false) | .space] | unique | sort | .[]
')

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
