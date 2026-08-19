#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Sumble in Cursor
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName Development
# @raycast.description Open the Sumble repo in Cursor.

set -euo pipefail

sumble_dir="/Users/apurvashukla/code/sumble"
 cursor_bin="/opt/homebrew/bin/code"

if [[ ! -d "$sumble_dir" ]]; then
  echo "Sumble folder not found: $sumble_dir"
  exit 1
fi

if [[ -x "$cursor_bin" ]]; then
  "$cursor_bin" "$sumble_dir"
else
  /usr/bin/open -a "Cursor" "$sumble_dir"
fi
