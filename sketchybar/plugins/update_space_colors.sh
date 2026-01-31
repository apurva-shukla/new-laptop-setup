#!/bin/bash

# Query yabai for windows and update space icons and colors
# Format: "1:AppName" for occupied, "1" for empty (yellow)

get_short_name() {
    case "$1" in
        "Google Chrome") echo "Chrome" ;;
        "Visual Studio Code") echo "Code" ;;
        "Microsoft Edge") echo "Edge" ;;
        "Adobe Photoshop") echo "Photoshop" ;;
        "Adobe Illustrator") echo "Illustrator" ;;
        "Microsoft Word") echo "Word" ;;
        "Microsoft Excel") echo "Excel" ;;
        "Brave Browser") echo "Brave" ;;
        "Terminal") echo "Term" ;;
        "iTerm2") echo "iTerm" ;;
        "Screen Studio") echo "Screen" ;;
        *) echo "$1" ;;
    esac
}

# Get data once
SPACE_COUNT=$(yabai -m query --spaces 2>/dev/null | jq 'length // 0')
[ "$SPACE_COUNT" -gt 10 ] && SPACE_COUNT=10
[ "$SPACE_COUNT" -eq 0 ] && exit 0

# Get all apps per space in one jq call: "space:app" per line
# Filter out minimized and hidden windows (but keep windows on non-active spaces)
space_apps=$(yabai -m query --windows 2>/dev/null | jq -r '
  [.[] | select(."is-minimized" == false and ."is-hidden" == false)]
  | group_by(.space) | .[] | "\(.[0].space):\(.[0].app)"
')

# Build single sketchybar command
args=()
for i in $(seq 1 $SPACE_COUNT); do
    # Find app for this space
    app=$(echo "$space_apps" | grep "^$i:" | cut -d: -f2 | head -1)

    if [ -n "$app" ]; then
        short_name=$(get_short_name "$app")
        args+=(--set space.$i icon="$i:$short_name" icon.color=0x4dffffff)
    else
        args+=(--set space.$i icon="$i" icon.color=0xffe7c664)
    fi
done

# Single atomic update
[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
