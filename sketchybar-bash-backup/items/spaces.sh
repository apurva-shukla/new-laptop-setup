#!/usr/bin/env bash

source "$HOME/.config/sketchybar/variables.sh"

# Dynamically add spaces for all existing spaces
for sid in $(yabai -m query --spaces | jq '.[].index'); do
	sketchybar --add space space.$sid left \
		--set space.$sid associated_space=$sid \
		icon="$sid" \
		label.drawing=off \
		icon.padding_left=8 \
		icon.padding_right=8 \
		background.corner_radius=5 \
		background.height=20 \
		script="$PLUGIN_DIR/space.sh" \
		click_script="yabai -m space --focus $sid" \
		--subscribe space.$sid space_change mouse.clicked
done

sketchybar --add item separator left \
	--set separator icon=│ \
	icon.font="$FONT:Regular:16.0" \
	icon.padding_left=10 \
	icon.padding_right=10 \
	label.drawing=off \
	icon.color="$COMMENT"