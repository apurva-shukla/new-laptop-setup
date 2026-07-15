#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Paste Latest Download Path
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName Downloads
# @raycast.description Copy the newest item in Downloads as a path and paste it into the active app.

set -euo pipefail

downloads_dir="${DOWNLOADS_DIR:-$HOME/Downloads}"

if [[ ! -d "$downloads_dir" ]]; then
  echo "Downloads folder not found: $downloads_dir"
  exit 1
fi

latest_path="$(
  /usr/bin/find "$downloads_dir" -mindepth 1 -maxdepth 1 -type f ! -name '.*' -exec /usr/bin/stat -f '%m	%N' {} + \
    | /usr/bin/sort -nr \
    | /usr/bin/head -n 1 \
    | /usr/bin/cut -f 2-
)"

if [[ -z "$latest_path" ]]; then
  echo "No downloaded files found"
  exit 1
fi

/bin/printf '%s' "$latest_path" | /usr/bin/pbcopy

# Let Raycast disappear, then paste into the app that was active before Raycast.
/bin/sleep 0.15
/usr/bin/osascript -e 'tell application "System Events" to keystroke "v" using command down'
