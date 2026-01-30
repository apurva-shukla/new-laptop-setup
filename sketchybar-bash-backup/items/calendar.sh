#!/usr/bin/env bash

sketchybar --add item calendar right \
  --set calendar \
    script="$HOME/.config/sketchybar/plugins/calendar.sh" \
    icon=󰃭 \
    updates=on \
    update_freq=10 \
    click_script="osascript -e 'tell application \"System Events\" to tell process \"Itsycal\" to click menu bar item 1 of menu bar 2'"


