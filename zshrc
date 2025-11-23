alias docs="cd ~/Documents"
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