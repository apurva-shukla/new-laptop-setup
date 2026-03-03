#!/usr/bin/env bash

set -euo pipefail

if ! command -v osascript >/dev/null 2>&1; then
  exit 0
fi

# Key codes: 4=21, 5=23, 6=22
case "${1:-}" in
  4) keycode=21 ;;
  5) keycode=23 ;;
  6) keycode=22 ;;
  *)
    echo "Usage: switch_space.sh {4|5|6}" >&2
    exit 2
    ;;
esac

osascript -e "tell application \"System Events\" to key code $keycode using option down"
