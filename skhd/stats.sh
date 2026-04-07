#!/usr/bin/env bash
set -euo pipefail

# Show skhd keybinding usage stats.
# Usage: stats.sh [days]   (default: 7)

SKHD_LOG="${SKHD_LOG:-$HOME/.local/share/skhd/usage.log}"

if [ ! -f "$SKHD_LOG" ]; then
    echo "No usage log found at $SKHD_LOG"
    echo "Use your skhd shortcuts for a while, then run this again."
    exit 0
fi

days="${1:-7}"
cutoff="$(date -v-"${days}"d '+%Y-%m-%d' 2>/dev/null || date -d "$days days ago" '+%Y-%m-%d' 2>/dev/null)" || cutoff=""

echo "=== skhd usage stats (last $days days) ==="
echo

# All known actions (title + body pairs from skhdrc)
declare -a ALL_ACTIONS=(
    "Focus|← West"
    "Focus|↓ South"
    "Focus|↑ North"
    "Focus|→ East"
    "Split|Toggled split"
    "Space Skip|ON"
    "Space Skip|OFF"
    "Layout|Rotated 90°"
    "Layout|Mirrored Y-axis"
    "Swap|← West"
    "Swap|↓ South"
    "Swap|↑ North"
    "Swap|→ East"
    "Warp|← West"
    "Warp|↓ South"
    "Warp|↑ North"
    "Warp|→ East"
    "Layout|BSP tiling"
    "Layout|Floating"
    "Resize|← Grow left"
    "Resize|↓ Grow down"
    "Resize|↑ Grow up"
    "Resize|→ Grow right"
    "Resize|← Shrink right"
    "Resize|↑ Shrink down"
    "Resize|↓ Shrink up"
    "Resize|→ Shrink left"
    "yabai|Restarting…"
    "Space 1|Chrome"
    "Space 2|Slack"
    "Space 3|Flex 1"
    "Space 4|Flex 2"
    "Space 5|Zen"
    "Space 6|Messaging"
    "Move → Space 1|Chrome"
    "Move → Space 2|Slack"
    "Move → Space 3|Flex 1"
    "Move → Space 4|Flex 2"
    "Move → Space 5|Zen"
    "Move → Space 6|Messaging"
    "Nav|→ Next space"
    "Nav|← Prev space"
    "Nav|→ Next occupied"
    "Nav|← Prev occupied"
)

# Filter log to the time window
if [ -n "$cutoff" ]; then
    filtered="$(awk -F'\t' -v cutoff="$cutoff" '$1 >= cutoff' "$SKHD_LOG")"
else
    filtered="$(cat "$SKHD_LOG")"
fi

total="$(echo "$filtered" | grep -c . || true)"
echo "Total actions: $total"
echo

# Count by category (title column)
echo "--- By category ---"
echo "$filtered" | awk -F'\t' '{print $2}' | sort | uniq -c | sort -rn | while read -r count cat; do
    printf "  %4d  %s\n" "$count" "$cat"
done
echo

# Top actions
echo "--- Most used ---"
echo "$filtered" | awk -F'\t' '{print $2 " → " $3}' | sort | uniq -c | sort -rn | head -10 | while read -r count action; do
    printf "  %4d  %s\n" "$count" "$action"
done
echo

# Never used
echo "--- Never used (last $days days) ---"
used_actions="$(echo "$filtered" | awk -F'\t' '{print $2 "|" $3}' | sort -u)"
any_unused=false
for action in "${ALL_ACTIONS[@]}"; do
    if ! echo "$used_actions" | grep -qF "$action"; then
        title="${action%%|*}"
        body="${action#*|}"
        echo "  $title → $body"
        any_unused=true
    fi
done
$any_unused || echo "  (none — you use everything!)"
echo

# Busiest hours
echo "--- Busiest hours ---"
echo "$filtered" | awk -F'\t' '{split($1, a, " "); split(a[2], t, ":"); print t[1] ":00"}' | sort | uniq -c | sort -rn | head -5 | while read -r count hour; do
    printf "  %4d  %s\n" "$count" "$hour"
done
