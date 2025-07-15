# =============================================================================
#                               Node.js/nvm Configuration
# =============================================================================

# nvm setup - try multiple possible locations
export NVM_DIR="$HOME/.nvm"

# Try multiple common nvm installation paths
for nvm_path in "$HOME/.nvm" "/opt/homebrew/opt/nvm" "/usr/local/opt/nvm" "/usr/share/nvm"; do
    if [[ -s "$nvm_path/nvm.sh" ]]; then
        export NVM_DIR="$nvm_path"
        source "$nvm_path/nvm.sh"
        # Load nvm bash completion if available
        [[ -s "$nvm_path/etc/bash_completion.d/nvm" ]] && source "$nvm_path/etc/bash_completion.d/nvm"
        [[ -s "$nvm_path/bash_completion" ]] && source "$nvm_path/bash_completion"
        break
    fi
done 

# Node.js settings
export NODE_REPL_HISTORY_FILE="$XDG_STATE_HOME/node/repl_history"
export NODE_REPL_HISTORY_SIZE='32768'
export NODE_OPTIONS="--max-old-space-size=4096"  # Increase Node.js memory limit

# npm configuration
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
# Set NODE_PATH dynamically based on npm global prefix
if command -v npm >/dev/null 2>&1; then
    export NODE_PATH="$(npm config get prefix)/lib/node_modules"
fi

# Yarn configuration
command -v yarn >/dev/null 2>&1 && export YARN_PATH="$HOME/.yarn"