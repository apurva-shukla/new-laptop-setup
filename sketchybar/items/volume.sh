#!/usr/bin/env bash

sketchybar --add item volume right \
  --set volume \
    script="$HOME/.config/sketchybar/plugins/volume.sh" \
    updates=on \
  --subscribe volume volume_change


