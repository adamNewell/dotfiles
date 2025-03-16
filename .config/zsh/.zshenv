# =============================================================================
#                               XDG Base Directory
# =============================================================================

# Set XDG variables first as they're needed for other configurations
# Using := operator for default values if not already set
: ${XDG_CONFIG_HOME:=$HOME/.config}
: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_STATE_HOME:=$HOME/.local/state}
: ${XDG_DATA_HOME:=$HOME/.local/share}
: ${XDG_BIN_HOME:=$HOME/.local/bin}
: ${XDG_LIB_HOME:=$HOME/.local/lib}

# =============================================================================
#                               ZSH Configuration
# =============================================================================

# Set ZDOTDIR early to ensure other zsh files are loaded from correct location
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

# =============================================================================
#                               Path Configuration
# =============================================================================

# Add system paths first (will be prepended to by tool-specific paths)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Initialize Homebrew if available (will prepend its paths)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
