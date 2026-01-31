#!/bin/bash

# Focus previous space that has non-minimized, non-hidden windows
# Wraps around to last occupied space if at beginning

current=$(yabai -m query --spaces --space | jq '.index')

# Get list of occupied spaces (spaces with visible windows), reversed
occupied=$(yabai -m query --windows | jq -r '
  [.[] | select(."is-minimized" == false and ."is-hidden" == false) | .space] | unique | sort | reverse | .[]
')

# Find previous occupied space before current
prev=""
for s in $occupied; do
    if [ "$s" -lt "$current" ]; then
        prev=$s
        break
    fi
done

# Wrap around if no prev found
if [ -z "$prev" ]; then
    for s in $occupied; do
        if [ "$s" -ne "$current" ]; then
            prev=$s
            break
        fi
    done
fi

# Focus the space if found
if [ -n "$prev" ]; then
    yabai -m space --focus "$prev"
fi
