# New Laptop Setup

## Order of Operations

1. **Run Sumble dev setup script**
   ```bash
   source <(curl -fsSL https://setup.sumble.com)
   ```
   This installs: pyenv, nvm, gcloud, sumble CLI, and work dependencies.

2. **Clone this repo and run Brewfile**
   ```bash
   cd ~/Developer/personal-github/new-laptop-setup
   brew bundle
   ```

3. **Copy zshrc content to ~/.zshrc** (prepend before Sumble additions)
   ```bash
   cat zshrc ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc
   ```

4. **Set up symlinks for configs**
   ```bash
   ln -sf ~/Developer/personal-github/new-laptop-setup/ghostty ~/.config/ghostty
   ln -sf ~/Developer/personal-github/new-laptop-setup/skhd ~/.config/skhd
   ln -sf ~/Developer/personal-github/new-laptop-setup/yabai ~/.config/yabai
   ln -sf ~/Developer/personal-github/new-laptop-setup/starship/starship.toml ~/.config/starship.toml
   ln -sf ~/Developer/personal-github/new-laptop-setup/sketchybar ~/.config/sketchybar
   ```

5. **Copy git configs**
   ```bash
   cp gitconfig ~/.gitconfig
   cp gitconfig-personal ~/.gitconfig-personal
   cp gitconfig-work ~/.gitconfig-work
   ```

6. **Start yabai and skhd**
   ```bash
   yabai --start-service
   skhd --start-service
   ```

## Manual Install Apps (not available via Homebrew)

- **DaVinci Resolve** - https://www.blackmagicdesign.com/products/davinciresolve
- **Affinity Suite** - https://affinity.serif.com
- **Cold Turkey Blocker** - https://getcoldturkey.com
- **Jabra Direct** - https://www.jabra.com/software-and-services/jabra-direct
