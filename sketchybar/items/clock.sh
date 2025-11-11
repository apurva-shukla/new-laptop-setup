#!/usr/bin/env bash

# Add a clock item on the right, updating every second
sketchybar --add item clock right \
  --set clock \
    script="$HOME/.config/sketchybar/plugins/clock.sh" \
    icon=󱑍 \
    update_freq=1 \
    label.drawing=on \
    updates=on


