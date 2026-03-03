# Audio Scripts Setup

## Prerequisites

```bash
brew install switchaudio-osx
```

## Raycast Installation

1. Open Raycast
2. Open Extensions (⌘ + ,)
3. Click "Script Commands" in the sidebar
4. Click "Add Directories"
5. Select this folder: `~/code/personal/new-laptop-setup/audio-scripts`

## Available Commands

| Command | Description |
|---------|-------------|
| Grado Audio Setup | Switch to Grado headphone setup |
| Webcam Audio Setup | Switch to webcam/video call setup |
| On the Move Audio | Switch to mobile/portable setup |

## Customization

Edit profile arrays in `switch-audio-profile.sh` to set device priority order.

- `webcam`
- `grado`
- `mobile`

The first available device in each list is selected.
