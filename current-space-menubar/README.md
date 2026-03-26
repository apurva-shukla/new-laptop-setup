# CurrentSpaceMenu

A tiny native macOS menu-bar app that shows the currently focused `yabai` space.

## What it does

- Shows the current space number in the Apple menu bar.
- Opens a dropdown menu listing all spaces from `yabai`.
- Lets you click a space in the menu to focus it.
- Runs as a menu-bar-only app (`LSUIElement`), so it does not show a Dock icon.

## Build

```sh
cd /Users/apurvashukla/code/personal/new-laptop-setup/current-space-menubar
./build.sh
```

That produces:

```text
build/CurrentSpaceMenu.app
```

## Run

```sh
open build/CurrentSpaceMenu.app
```

## Notes

- This app expects `yabai` to be installed at a standard location such as `/opt/homebrew/bin/yabai`.
- The menu-bar title only shows the current space number to keep the item narrow.
- The dropdown shows the space label too when one exists.
