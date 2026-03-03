#!/usr/bin/env bash

set -euo pipefail

case "${OSTYPE:-}" in
  darwin*) ;;
  *)
    echo "This script only supports macOS." >&2
    exit 1
    ;;
esac

if [ "${1:-}" != "--allow-insecure" ]; then
  cat >&2 <<'EOF'
Refusing to apply insecure system defaults without explicit confirmation.

This script will:
- disable Launch Services quarantine prompts
- disable Gatekeeper checks

Run with:
  ./macos-defaults.sh --allow-insecure
EOF
  exit 2
fi

if ! command -v defaults >/dev/null 2>&1 || ! command -v spctl >/dev/null 2>&1; then
  echo "Missing required macOS commands (defaults/spctl)." >&2
  exit 1
fi

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Allow running files downloaded from the internet
sudo spctl --master-disable

killall Dock || true
