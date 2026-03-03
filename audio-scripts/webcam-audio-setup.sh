#!/usr/bin/env bash

set -euo pipefail

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Webcam Audio Setup
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📹
# @raycast.packageName Audio

# Documentation:
# @raycast.description Switch to webcam audio setup for video calls
# @raycast.author Apurva Shukla

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/switch-audio-profile.sh" webcam
