# =============================================================================
#                               Development Tools
# =============================================================================

# =============================================================================
#                               Node.js/nvm
# =============================================================================
export NVM_DIR="$HOME/.nvm"
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    source "/opt/homebrew/opt/nvm/nvm.sh"
    [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi 

# Node.js settings
export NODE_REPL_HISTORY_FILE=~/.node_history
export NODE_REPL_HISTORY_SIZE='32768'
export NODE_OPTIONS="--max-old-space-size=4096"  # Increase Node.js memory limit

# =============================================================================
#                               Python/pyenv
# =============================================================================
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init - zsh)"
fi
[[ -d "$PYENV_ROOT/bin" ]] && PATH="$PYENV_ROOT/bin:$PATH"

# Python settings
export PYTHONDONTWRITEBYTECODE=1  # Prevent Python from writing .pyc files
export PYTHONUNBUFFERED=1         # Force Python to run in unbuffered mode
