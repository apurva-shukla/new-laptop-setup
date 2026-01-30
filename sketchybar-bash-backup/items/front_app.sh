#!/usr/bin/env bash

# Create an item showing the focused app name on the left
sketchybar --add item front_app left \
  --set front_app \
    script="$HOME/.config/sketchybar/plugins/front_app.sh" \
    icon=󰣆 \
    label.drawing=on \
    updates=on \
  --subscribe front_app front_app_switched


