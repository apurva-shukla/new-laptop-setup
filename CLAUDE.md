# New Laptop Setup

Dotfiles and config for macOS dev environment. Idempotent bootstrap script symlinks everything into place.

## Philosophy

- **ijkl navigation everywhere** — Vim-style but shifted right (i=up, j=left, k=down, l=right)
- **Catppuccin Mocha** — Consistent dark theme across Ghostty and tmux
- **Tiling-first** — AeroSpace tiling; floating only for system dialogs

## Tool Stack

| Tool | Purpose | Config File |
|------|---------|-------------|
| Ghostty | Terminal emulator | `ghostty/config` |
| tmux | Terminal multiplexer | `tmux/tmux.conf` |
| AeroSpace | Tiling window manager | `aerospace/aerospace.toml` |
| Starship | Shell prompt | `starship.toml` |
| zsh | Shell | `zshrc` |

## Keybindings Quick Reference

### AeroSpace (Window Management)
- Workspaces and keybindings live in `aerospace/aerospace.toml`

### tmux (Prefix: Ctrl+Space)
- `prefix + i/j/k/l` — Navigate panes (up/left/down/right)
- `prefix + \` or `alt + \` — Horizontal split (side-by-side)
- `prefix + -` or `alt + -` — Vertical split (stacked)
- `alt + 1-9` — Switch window (no prefix needed)
- `prefix + r` — Reload config
- Mouse mode is ON

### Ghostty
- CommitMono font, size 14, 0.90 opacity
- Auto-launches tmux on open
- macOS-style keybindings (Cmd+C/V for copy/paste)

## Bootstrap

```bash
# Fresh machine setup (idempotent — safe to re-run):
./bootstrap.sh
```

What it does:
1. Symlinks all config files to their expected locations (`~/.config/ghostty/config`, `~/.tmux.conf`, etc.)
2. Installs Homebrew packages from `Brewfile`
3. Starts the Herdr service

## Shell (zsh)

- Prompt: Starship
- Plugins: zsh-syntax-highlighting, fzf, zoxide
- Aliases: `ls`→`eza`, `cat`→`bat`

## Known Issues

- **tmux copy mode** — Use `prefix + [` to enter, `q` to exit; mouse selection auto-copies

## Working With This Project

- All configs are source-of-truth in this repo — edit here, then `./bootstrap.sh` to apply
- After adding a new tool, add its config file and update `bootstrap.sh` with the symlink
- Test keybinding changes by reloading: `aerospace reload-config` / `tmux source ~/.tmux.conf`
- When I say "add a keybinding", edit the appropriate config file (aerospace.toml for window management, tmux.conf for terminal)
