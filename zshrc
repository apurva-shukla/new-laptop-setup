# === PERSONAL CUSTOMIZATIONS ===
alias dev="cd ~/code"
alias reload="source ~/.zshrc"

# --- Starship Prompt (Makes the path/git look cool) ---
eval "$(starship init zsh)"

# --- Syntax Highlighting (Colors commands while typing) ---
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Auto Suggestions (Grey ghost text history) ---
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Setup FZF (allows Ctrl+R to fuzzy search history)
source <(fzf --zsh)

# Initialize Zoxide (better cd)
eval "$(zoxide init zsh)"

# Modern ls replacement
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"

# Modern cat replacement
alias cat="bat"

# Lazygit
alias lg="lazygit"

# Zed editor (VS Code muscle memory)
alias code="zed"

# Safety: Use 'del' to move to Trash instead of 'rm' (permanent delete)
alias del="trash"

# Prompt before deleting more than 3 files or recursive delete
alias rm="rm -i"

# Add local binaries (needed for uv, pipx, etc)
export PATH="$HOME/.local/bin:$PATH"

# === SUMBLE SETUP SCRIPT WILL ADD BELOW ===
# The following will be added by `source <(curl -fsSL https://setup.sumble.com)`:
# - pyenv + pyenv-virtualenv (Python version management)
# - nvm (Node version management)
# - gcloud SDK
# - sumble CLI
