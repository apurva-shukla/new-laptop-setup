#!/usr/bin/env bash

# Workaround for the macOS Tahoe raise race (AeroSpace discussion #1728):
# AeroSpace's focus change always succeeds internally, but the window raise
# often fails — and on Tahoe an app can even become frontmost while its window
# stays buried in z-order. So this hook unconditionally re-raises the focused
# window after every focus change, using the strongest public primitives:
# 'set frontmost' on the process + AXRaise on its focused window.
# Raising an already-top window is a no-op, so this is always safe.
#
# Wired via on-focus-changed in aerospace.toml. Safe to delete once upstream
# fixes land (check after `brew upgrade aerospace`).

[ -n "${AEROSPACE_WINDOW_ID:-}" ] || exit 0

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

for attempt in 1 2; do
  sleep 0.10

  # If focus has already moved to a different window, a newer instance of this
  # script owns the problem — bail out so we don't fight it.
  now="$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)" || exit 0
  [ "$now" = "$AEROSPACE_WINDOW_ID" ] || exit 0

  bid="$(aerospace list-windows --focused --format '%{app-bundle-id}' 2>/dev/null)" || exit 0
  [ -n "$bid" ] || exit 0

  # Observability: log when the app didn't even own the keyboard (worst case).
  front="$(osascript -e 'tell application "System Events" to get bundle identifier of first application process whose frontmost is true' 2>/dev/null)"
  if [ "$front" != "$bid" ]; then
    echo "$(date '+%H:%M:%S') rescuing: win=$AEROSPACE_WINDOW_ID attempt=$attempt want=$bid front=$front" >> "$HOME/.config/aerospace/raise-debug.log"
  fi

  osascript >/dev/null 2>&1 <<APPLESCRIPT
tell application "System Events"
  tell (first application process whose bundle identifier is "$bid")
    set frontmost to true
    try
      perform action "AXRaise" of (value of attribute "AXFocusedWindow")
    end try
  end tell
end tell
APPLESCRIPT
done
