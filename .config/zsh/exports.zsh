# =============================================================================
#                               XDG Base Directory
# =============================================================================

# Export XDG vars without values - they're set in .zshenv
export XDG_CONFIG_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_BIN_HOME XDG_LIB_HOME 

# =============================================================================
#                               Core Environment
# =============================================================================

# Editor and terminal
export EDITOR='nvim'
export VISUAL='nvim'
export TERM='xterm-256color'

# Locale
export LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# History
export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTSIZE=1000000
export SAVEHIST=1000000

# =============================================================================
#                               Tool Configurations
# =============================================================================

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# BAT
export BAT_THEME="Monokai Extended Bright"

# RIPGREP
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# Node.js
export NODE_PATH="/opt/homebrew/lib/node_modules"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

# Go
export GOPATH="$HOME/go"
export GOROOT="/opt/homebrew/opt/go/libexec"
export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

# Yarn
export YARN_PATH="$HOME/.yarn"
export PATH="$YARN_PATH/bin:$PATH"

# =============================================================================
#                               Cleanup
# =============================================================================

# Unset deprecated options
unset GREP_OPTIONS