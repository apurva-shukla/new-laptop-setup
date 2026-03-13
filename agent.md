# New Laptop Setup

Dotfiles and config for macOS dev environment. Idempotent bootstrap script symlinks everything into place.

## Philosophy

- **ijkl navigation everywhere** — Vim-style but shifted right (i=up, j=left, k=down, l=right) across tmux, yabai/skhd
- **Catppuccin Mocha** — Consistent dark theme across Ghostty, tmux, sketchybar
- **Tiling-first** — yabai BSP layout with skhd keybindings; floating only for system dialogs

## Tool Stack

| Tool | Purpose | Config File |
|------|---------|-------------|
| Ghostty | Terminal emulator | `ghostty/config` |
| tmux | Terminal multiplexer | `tmux/tmux.conf` |
| yabai | Tiling window manager | `yabai/yabairc` |
| skhd | Hotkey daemon | `skhd/skhdrc` |
| sketchybar | Menu bar | `sketchybar/` |
| Starship | Shell prompt | `starship.toml` |
| zsh | Shell | `zshrc` |

## Keybindings Quick Reference

### skhd (Window Management)
- `alt + i/j/k/l` — Focus window (up/left/down/right)
- `shift + alt + i/j/k/l` — Swap window
- `ctrl + alt + i/j/k/l` — Resize window
- `alt + b` — BSP layout
- `alt + f` — Float layout
- `cmd + 1-6` — Switch to space (Chrome/Slack/Flex1/Flex2/Zen/Messaging)
- `shift + cmd + 1-6` — Move window to space

### tmux (Prefix: Ctrl+Space)
- `prefix + i/j/k/l` — Navigate panes (up/left/down/right)
- `prefix + s` — Horizontal split
- `prefix + v` — Vertical split
- `alt + 1-9` — Switch window (no prefix needed)
- `prefix + r` — Reload config
- Mouse mode is ON

### Ghostty
- CommitMono font, size 14, 0.90 opacity
- Auto-launches tmux on open
- macOS-style keybindings (Cmd+C/V for copy/paste)

## Space Layout (yabai)

| Space | Label | Purpose |
|-------|-------|---------|
| 1 | chrome | Web browsing |
| 2 | slack | Communication |
| 3 | flex1 | Development |
| 4 | flex2 | Development |
| 5 | zen | Focus/distraction-free |
| 6 | messaging | Personal messaging |

## Bootstrap

```bash
# Fresh machine setup (idempotent — safe to re-run):
./bootstrap.sh
```

What it does:
1. Symlinks all config files to their expected locations (`~/.config/ghostty/config`, `~/.tmux.conf`, etc.)
2. Installs Homebrew packages from `Brewfile`
3. Starts yabai, skhd, and sketchybar services
4. Installs the SketchyBar watchdog LaunchAgent in `~/Library/LaunchAgents`

## Shell (zsh)

- Prompt: Starship
- Plugins: zsh-syntax-highlighting, fzf, zoxide
- Aliases: `ls`→`eza`, `cat`→`bat`
- sketchybar auto-restarts on zshrc reload

## SketchyBar Notes

- Active config is the repo copy symlinked at `~/.config/sketchybar`
- Space updates are now driven by explicit yabai window signals instead of generic app-switch refreshes
- `yabai_mode` no longer polls every 2 seconds; it updates on events
- A watchdog checks `sketchybar --query bar` every 60 seconds and restarts SketchyBar if the bar deadlocks
- Watchdog logs go to `/tmp/sketchybar_watchdog.log`
- If the watchdog restarts the bar, it also captures `sample` output in `/tmp/sketchybar*.sample.txt`

## Known Issues

- **sketchybar UI deadlock** — Rarely the bar can hang and show a spinning cursor on hover; the watchdog should recover it within 60 seconds
- **yabai scripting addition** — Requires partially disabling SIP; re-run `sudo yabai --load-sa` after macOS updates
- **tmux copy mode** — Use `prefix + [` to enter, `q` to exit; mouse selection auto-copies

## Working With This Project

- All configs are source-of-truth in this repo — edit here, then `./bootstrap.sh` to apply
- After adding a new tool, add its config file and update `bootstrap.sh` with the symlink
- Test keybinding changes by reloading: `skhd --reload` / `tmux source ~/.tmux.conf` / `yabai --restart-service`
- For SketchyBar changes, use `brew services restart sketchybar` if a plain reload is not enough
- When I say "add a keybinding", edit the appropriate config file (skhdrc for window management, tmux.conf for terminal)
