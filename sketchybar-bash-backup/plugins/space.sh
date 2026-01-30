#!/bin/bash

source "$HOME/.config/sketchybar/variables.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$BLUE" \
    background.corner_radius=5 \
    icon.color="$BLACK"
else
  sketchybar --set "$NAME" \
    background.drawing=off \
    icon.color="$WHITE"
fi
