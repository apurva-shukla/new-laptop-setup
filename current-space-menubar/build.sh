#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="CurrentSpaceMenu"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
MODULE_CACHE_DIR="$BUILD_DIR/module-cache"
SDK_PATH="$(xcrun --show-sdk-path)"

mkdir -p "$MACOS_DIR"
mkdir -p "$MODULE_CACHE_DIR"

xcrun swiftc \
  "$ROOT_DIR/Sources/main.swift" \
  -O \
  -target arm64-apple-macos13.0 \
  -sdk "$SDK_PATH" \
  -module-cache-path "$MODULE_CACHE_DIR" \
  -framework AppKit \
  -o "$MACOS_DIR/$APP_NAME"

cp "$ROOT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true
fi

echo "Built $APP_DIR"
