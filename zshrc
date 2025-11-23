alias dev="cd ~/Developer"
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

# Node Version Manager
eval "$(fnm env --use-on-cd)"

# Safety: Use 'del' to move to Trash instead of 'rm' (permanent delete)
alias del="trash"

# Prompt before deleting more than 3 files or recursive delete
alias rm="rm -i"

# Add local binaries (needed for uv, pipx, etc)
export PATH="$HOME/.local/bin:$PATH"
