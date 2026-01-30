#!/usr/bin/env bash

sketchybar --add item battery right \
  --set battery \
    script="$HOME/.config/sketchybar/plugins/battery.sh" \
    updates=on \
    background.padding_left=10 \
  --subscribe battery system_woke power_source_change


