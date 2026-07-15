#!/usr/bin/env bash

set -euo pipefail

# Port of ~/.config/skhd/move_to_next_free_space.sh for AeroSpace.
# Moves the focused window to the next empty workspace (after the current one,
# wrapping around) and follows it. Notifies if every workspace is occupied.

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

command -v aerospace >/dev/null 2>&1 || exit 0

notify() {
  osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1 || true
}

WORKSPACES=(1-chrome 2-slack 3-flex1 4-flex2 5-zen 6-messaging)

current="$(aerospace list-workspaces --focused)"

cur_idx=0
for i in "${!WORKSPACES[@]}"; do
  if [ "${WORKSPACES[$i]}" = "$current" ]; then
    cur_idx="$i"
  fi
done

total="${#WORKSPACES[@]}"
target=""
offset=1
while [ "$offset" -lt "$total" ]; do
  idx=$(( (cur_idx + offset) % total ))
  ws="${WORKSPACES[$idx]}"
  count="$(aerospace list-windows --workspace "$ws" 2>/dev/null | grep -c . || true)"
  if [ "${count:-0}" -eq 0 ]; then
    target="$ws"
    break
  fi
  offset=$((offset + 1))
done

if [ -z "$target" ]; then
  notify "Workspaces" "No free workspaces right now"
  exit 0
fi

aerospace move-node-to-workspace --focus-follows-window "$target"
notify "Move → Free Workspace" "$target"
