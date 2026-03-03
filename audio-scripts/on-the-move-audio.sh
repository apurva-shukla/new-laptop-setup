#!/usr/bin/env bash

set -euo pipefail

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title On the Move Audio
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🚶
# @raycast.packageName Audio

# Documentation:
# @raycast.description Switch to mobile/portable audio setup
# @raycast.author Apurva Shukla

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/switch-audio-profile.sh" mobile
