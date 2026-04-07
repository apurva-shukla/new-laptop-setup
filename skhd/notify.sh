#!/usr/bin/env bash
# Runs a command, logs it, and shows a macOS notification.
# Usage: notify.sh "Title" "Body" cmd [args...]
SKHD_LOG="${SKHD_LOG:-$HOME/.local/share/skhd/usage.log}"
title="$1"; body="$2"; shift 2
"$@"
mkdir -p "$(dirname "$SKHD_LOG")"
printf '%s\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$title" "$body" >> "$SKHD_LOG"
osascript -e "display notification \"$body\" with title \"$title\"" &>/dev/null &
