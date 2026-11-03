# BetterTouchTool Setup

## Before Reset - Export Your Preset

The preset is saved here, but you need to export it manually:

1. Open BetterTouchTool
2. Go to **Presets** (top left dropdown)
3. Click **Export Preset**
4. Save as `my-preset.bttpreset` in this folder
5. Commit and push

## After Reset - Import

1. Install BTT from https://folivora.ai (not Homebrew — see below)
2. Create a local license file from template:
   - `cp bettertouchtool.bttlicense.example bettertouchtool.bttlicense`
   - Fill in your real license values
3. Open BTT and activate with the local license file
4. Go to **Presets** → **Import Preset**
5. Select your `.bttpreset` file
   - Or from the CLI: `osascript -e 'tell application "BetterTouchTool" to import_preset "'"$PWD"'/my-preset.bttpreset"'`

## License

`bettertouchtool.bttlicense` (local, ignored by git) - copy to `~/Library/Application Support/BetterTouchTool/`

## Don't Install via Homebrew

BTT warns against Homebrew installs. `brew upgrade --greedy` / `brew reinstall` delete and replace the app, which can
silently invalidate its Accessibility permission — and then a permission dialog can freeze all mouse/keyboard input.

- Update BTT only with its built-in updater
- If BTT was ever reinstalled by Homebrew: quit BTT, remove and re-add it in
  System Settings → Privacy & Security → Accessibility, then relaunch
