#!/usr/bin/env bash

set -euo pipefail

# Query yabai for windows and update space icons and colors
# Format: "1:AppName" for occupied, "1" for empty (yellow)

if ! command -v yabai >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1 || ! command -v sketchybar >/dev/null 2>&1; then
    exit 0
fi

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

# Get data once — exit silently if yabai is unavailable or returns bad JSON
spaces_json=$(yabai -m query --spaces 2>/dev/null) || exit 0
SPACE_COUNT=$(echo "$spaces_json" | jq 'length // 0' 2>/dev/null) || exit 0
[ -z "$SPACE_COUNT" ] || [ "$SPACE_COUNT" = "null" ] && exit 0
[ "$SPACE_COUNT" -gt 10 ] 2>/dev/null && SPACE_COUNT=10
[ "$SPACE_COUNT" -eq 0 ] 2>/dev/null && exit 0

# Get all apps per space in one jq call: "space:app" per line
# Filter out minimized and hidden windows (but keep windows on non-active spaces)
windows_json=$(yabai -m query --windows 2>/dev/null) || exit 0
space_apps=$(echo "$windows_json" | jq -r '
  [.[] | select(."is-minimized" == false and ."is-hidden" == false)]
  | group_by(.space) | .[] | "\(.[0].space):\(.[0].app)"
' 2>/dev/null) || exit 0

# Build single sketchybar command
args=()
for i in $(seq 1 $SPACE_COUNT); do
    # Find app for this space
    app=$(printf '%s\n' "$space_apps" | awk -F: -v idx="$i" '$1 == idx { print $2; exit }')

    if [ -n "$app" ]; then
        short_name=$(get_short_name "$app")
        args+=(--set space.$i icon="$i:$short_name" icon.color=0x4dffffff)
    else
        args+=(--set space.$i icon="$i" icon.color=0xffe7c664)
    fi
done

# Single atomic update
[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
