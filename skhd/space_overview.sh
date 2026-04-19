#!/usr/bin/env bash

set -euo pipefail

command -v yabai >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

spaces_json="$(yabai -m query --spaces 2>/dev/null)" || exit 0
windows_json="$(yabai -m query --windows 2>/dev/null)" || exit 0

summary="$(
  jq -nr \
    --argjson spaces "$spaces_json" \
    --argjson windows "$windows_json" '
      [
        $spaces[]
        | . as $space
        | {
            index: $space.index,
            label: ($space.label // ("space" + ($space.index | tostring))),
            count: (
              [
                $windows[]
                | select(.space == $space.index and ."is-hidden" == false and ."is-minimized" == false)
              ] | length
            )
          }
      ] as $summary
      | "Free: "
        + (
            $summary
            | map(select(.count == 0) | "\(.index) \(.label)")
            | if length == 0 then "none" else join(", ") end
          )
        + " | Busy: "
        + (
            $summary
            | map(select(.count > 0) | "\(.index) \(.label) (\(.count))")
            | if length == 0 then "none" else join(", ") end
          )
    '
)"

osascript -e "display notification \"$summary\" with title \"Spaces\"" >/dev/null 2>&1 || true
printf '%s\n' "$summary"
