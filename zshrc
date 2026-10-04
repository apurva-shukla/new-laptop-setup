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

# Quick Look keyboard layout reference
alias keys='open ~/.local/bin/FloatingImage.app --args ~/code/personal/new-laptop-setup/keys.png'

# `code` resolves to the real VS Code CLI at /opt/homebrew/bin/code

# Safety: Use 'del' to move to Trash instead of 'rm' (permanent delete)
alias del="trash"

# Prompt before deleting more than 3 files or recursive delete
alias rm="rm -i"

# Add local binaries (needed for uv, pipx, etc). ~/bin holds the scripts in bin/.
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# === SUMBLE SETUP ===
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# sumble cli (installed by `source <(curl -fsSL https://setup.sumble.com)`)
if [ -d /usr/local/sumble-cli ]; then
  export PATH=/usr/local/sumble-cli:${PATH}
  source /usr/local/sumble-cli/completions.sh
fi

# YNAB CLI
alias ynab="python3 $HOME/code/personal/financial-planning/ynab/cli.py"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# --- Secrets (API keys, tokens) and machine-only settings stay out of this repo ---
# ~/.zshrc sources this file, then adds anything personal below that line.
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets
