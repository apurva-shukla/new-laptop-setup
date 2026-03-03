#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [--skip-brew] [--skip-services]

Idempotent setup for this repository:
- installs Homebrew dependencies (optional)
- creates/updates symlinks
- adds one-time includes for zshrc and gitconfig
- creates local secret files from templates when missing
- starts yabai/skhd/sketchybar services (optional)
EOF
}

SKIP_BREW=false
SKIP_SERVICES=false

for arg in "$@"; do
  case "$arg" in
    --skip-brew)
      SKIP_BREW=true
      ;;
    --skip-services)
      SKIP_SERVICES=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage
      exit 1
      ;;
  esac
done

link_item() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "Linked $dst -> $src"
}

append_if_missing() {
  local target_file="$1"
  local line="$2"
  touch "$target_file"
  if ! grep -Fqx "$line" "$target_file"; then
    printf '\n%s\n' "$line" >> "$target_file"
    echo "Updated $target_file"
  fi
}

copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    echo "Created $dst from template"
  fi
}

echo "Repository: $REPO_DIR"

if [ "$SKIP_BREW" = false ]; then
  if command -v brew >/dev/null 2>&1; then
    brew bundle --file "$REPO_DIR/Brewfile"
  else
    echo "Homebrew not found. Skipping brew bundle."
  fi
fi

mkdir -p "$CONFIG_HOME"

link_item "$REPO_DIR/ghostty" "$CONFIG_HOME/ghostty"
link_item "$REPO_DIR/skhd" "$CONFIG_HOME/skhd"
link_item "$REPO_DIR/yabai" "$CONFIG_HOME/yabai"
link_item "$REPO_DIR/sketchybar" "$CONFIG_HOME/sketchybar"
link_item "$REPO_DIR/zed" "$CONFIG_HOME/zed"
link_item "$REPO_DIR/starship/starship.toml" "$CONFIG_HOME/starship.toml"
link_item "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

append_if_missing "$HOME/.zshrc" "source \"$REPO_DIR/zshrc\""

if [ -f "$HOME/.gitconfig" ]; then
  if ! grep -Fq "$REPO_DIR/gitconfig" "$HOME/.gitconfig"; then
    cat >> "$HOME/.gitconfig" <<EOF

[include]
    path = $REPO_DIR/gitconfig
EOF
    echo "Updated $HOME/.gitconfig"
  fi
else
  cat > "$HOME/.gitconfig" <<EOF
[include]
    path = $REPO_DIR/gitconfig
EOF
  echo "Created $HOME/.gitconfig"
fi

copy_if_missing "$REPO_DIR/raycast/config.example.json" "$REPO_DIR/raycast/config.json"
copy_if_missing "$REPO_DIR/bettertouchtool/bettertouchtool.bttlicense.example" "$REPO_DIR/bettertouchtool/bettertouchtool.bttlicense"

if [ "$SKIP_SERVICES" = false ]; then
  if command -v yabai >/dev/null 2>&1; then
    yabai --start-service || true
  fi
  if command -v skhd >/dev/null 2>&1; then
    skhd --start-service || true
  fi
  if command -v brew >/dev/null 2>&1; then
    brew services start sketchybar >/dev/null 2>&1 || true
  fi
fi

echo "Done."
