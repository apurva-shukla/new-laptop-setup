alias docs="cd ~/Documents"
alias reload="source ~/.zshrc"
# --- Starship Prompt (Makes the path/git look cool) ---
eval "$(starship init zsh)"

# --- Syntax Highlighting (Colors commands while typing) ---
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Auto Suggestions (Grey ghost text history) ---
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
