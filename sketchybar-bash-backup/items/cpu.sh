#!/usr/bin/env bash

sketchybar --add item cpu right \
  --set cpu \
    script="$HOME/.config/sketchybar/plugins/cpu.sh" \
    icon= \
    updates=on \
    update_freq=100