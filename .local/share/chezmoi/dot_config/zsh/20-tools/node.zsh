# =============================================================================
#                               Node.js/nvm Configuration
# =============================================================================

# nvm setup
export NVM_DIR="$HOME/.nvm"
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    source "/opt/homebrew/opt/nvm/nvm.sh"
    [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi 

# Node.js settings
export NODE_REPL_HISTORY_FILE="$XDG_STATE_HOME/node/repl_history"
export NODE_REPL_HISTORY_SIZE='32768'
export NODE_OPTIONS="--max-old-space-size=4096"  # Increase Node.js memory limit

# npm configuration
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"