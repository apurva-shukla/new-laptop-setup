#!/usr/bin/env bash
# Runs a command and shows a macOS notification.
# Usage: notify.sh "Title" "Body" cmd [args...]
title="$1"; body="$2"; shift 2
"$@"
osascript -e "display notification \"$body\" with title \"$title\"" &>/dev/null &
