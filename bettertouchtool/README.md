# BetterTouchTool Setup

## Before Reset - Export Your Preset

The preset is saved here, but you need to export it manually:

1. Open BetterTouchTool
2. Go to **Presets** (top left dropdown)
3. Click **Export Preset**
4. Save as `my-preset.bttpreset` in this folder
5. Commit and push

## After Reset - Import

1. Install BTT via `brew bundle`
2. Create a local license file from template:
   - `cp bettertouchtool.bttlicense.example bettertouchtool.bttlicense`
   - Fill in your real license values
3. Open BTT and activate with the local license file
4. Go to **Presets** → **Import Preset**
5. Select your `.bttpreset` file

## License

`bettertouchtool.bttlicense` (local, ignored by git) - copy to `~/Library/Application Support/BetterTouchTool/`
