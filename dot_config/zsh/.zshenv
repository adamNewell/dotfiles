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

# Ensure pip uses XDG locations (exported early so pip picks them up when invoked)
export PIP_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/pip"
export PIP_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/pip/pip.conf"

# =============================================================================
#                               ZSH Configuration
# =============================================================================

# Set ZDOTDIR early to ensure other zsh files are loaded from correct location
export ZDOTDIR=${XDG_CONFIG_HOME}/zsh

# Set update interval for zsh
export UPDATE_ZSH_DAYS=7

# =============================================================================
#                               Zinit Configuration
# =============================================================================

# Set up zinit environment variables
declare -A ZINIT
ZINIT[BIN_DIR]="${ZDOTDIR}/zinit"
ZINIT[HOME_DIR]="${XDG_DATA_HOME}/zinit"
ZINIT[PLUGINS_DIR]="${ZINIT[HOME_DIR]}/plugins"
ZINIT[COMPLETIONS_DIR]="${ZINIT[HOME_DIR]}/completions"
ZINIT[SNIPPETS_DIR]="${ZINIT[HOME_DIR]}/snippets"
ZINIT[ZCOMPDUMP_PATH]="${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"

# =============================================================================
#                               Path Configuration
# =============================================================================

# Add system paths first (will be prepended to by tool-specific paths)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Initialize Homebrew if available (will prepend its paths)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
