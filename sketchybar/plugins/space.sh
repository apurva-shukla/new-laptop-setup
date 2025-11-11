#!/bin/sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

. "$HOME/.config/sketchybar/variables.sh"

if [ "$SELECTED" = "on" ]; then
  # Subtle highlight and accent color for selected space
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=0x33565f89 \
    icon.color="$YELLOW"
else
  sketchybar --set "$NAME" \
    background.drawing=off \
    icon.color="$WHITE"
fi
