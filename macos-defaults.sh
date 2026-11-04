#!/usr/bin/env bash

set -euo pipefail

case "${OSTYPE:-}" in
  darwin*) ;;
  *)
    echo "This script only supports macOS." >&2
    exit 1
    ;;
esac

if ! command -v defaults >/dev/null 2>&1 || ! command -v spctl >/dev/null 2>&1; then
  echo "Missing required macOS commands (defaults/spctl)." >&2
  exit 1
fi

# Show the auto-hidden Dock instantly, with a short slide
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Faster Mission Control and window animations
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Faster key repeat (takes effect after logging out and back in)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

echo "Applied speed defaults."

if [ "${1:-}" != "--allow-insecure" ]; then
  killall Dock || true
  cat <<'EOF'
Skipped insecure defaults. To also:
- disable Launch Services quarantine prompts
- disable Gatekeeper checks

Run with:
  ./macos-defaults.sh --allow-insecure
EOF
  exit 0
fi

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Allow running files downloaded from the internet
sudo spctl --master-disable

killall Dock || true
