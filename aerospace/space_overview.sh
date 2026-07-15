#!/usr/bin/env bash

set -euo pipefail

# Port of ~/.config/skhd/space_overview.sh for AeroSpace.
# Shows a notification listing free vs busy workspaces (with window counts).

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

command -v aerospace >/dev/null 2>&1 || exit 0

WORKSPACES=(1-chrome 2-slack 3-flex1 4-flex2 5-zen 6-messaging)

free=()
busy=()
for ws in "${WORKSPACES[@]}"; do
  count="$(aerospace list-windows --workspace "$ws" 2>/dev/null | grep -c . || true)"
  count="${count:-0}"
  if [ "$count" -gt 0 ]; then
    busy+=("$ws ($count)")
  else
    free+=("$ws")
  fi
done

summary="Free: ${free[*]:-none} | Busy: ${busy[*]:-none}"

osascript -e "display notification \"$summary\" with title \"Workspaces\"" >/dev/null 2>&1 || true
printf '%s\n' "$summary"
