#!/usr/bin/env bash

set -euo pipefail

SKHD_LOG="${SKHD_LOG:-$HOME/.local/share/skhd/usage.log}"

log_action() {
  mkdir -p "$(dirname "$SKHD_LOG")"
  printf '%s\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >> "$SKHD_LOG"
}

notify() {
  local title="$1"
  local body="$2"
  osascript -e "display notification \"$body\" with title \"$title\"" >/dev/null 2>&1 || true
}

command -v yabai >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

spaces_json="$(yabai -m query --spaces 2>/dev/null)" || exit 0
windows_json="$(yabai -m query --windows 2>/dev/null)" || exit 0
current_space="$(printf '%s' "$spaces_json" | jq -r '.[] | select(."has-focus" == true) | .index')"

mapfile -t spaces < <(
  printf '%s' "$spaces_json" \
    | jq -r 'sort_by(.index)[] | "\(.index)\t\(.label // ("space" + (.index | tostring)))"'
)

mapfile -t occupied < <(
  printf '%s' "$windows_json" \
    | jq -r '
        [
          .[]
          | select(."is-hidden" == false and ."is-minimized" == false)
          | .space
        ]
        | unique
        | sort
        | .[]
      '
)

is_occupied() {
  local target="$1"
  local s
  for s in "${occupied[@]:-}"; do
    [ "$s" = "$target" ] && return 0
  done
  return 1
}

next_space=""
next_label=""
wrapped_space=""
wrapped_label=""

for entry in "${spaces[@]}"; do
  index="${entry%%$'\t'*}"
  label="${entry#*$'\t'}"

  if is_occupied "$index"; then
    continue
  fi

  if [ "$index" -gt "$current_space" ] && [ -z "$next_space" ]; then
    next_space="$index"
    next_label="$label"
  fi

  if [ -z "$wrapped_space" ]; then
    wrapped_space="$index"
    wrapped_label="$label"
  fi
done

target_space="${next_space:-$wrapped_space}"
target_label="${next_label:-$wrapped_label}"

if [ -z "$target_space" ]; then
  notify "Spaces" "No free spaces right now"
  log_action "Move → Free Space" "No free spaces"
  exit 0
fi

yabai -m window --space "$target_space"
yabai -m space --focus "$target_space"

log_action "Move → Free Space" "$target_space $target_label"
notify "Move → Free Space" "$target_space $target_label"
