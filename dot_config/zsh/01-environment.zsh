# =============================================================================
#                               Environment Variables
# =============================================================================
# Core environment setup - loaded first to establish baseline

# XDG Base Directory Specification
# Note: XDG_CONFIG_HOME is set in .zshenv, we just export here
export XDG_CONFIG_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_BIN_HOME XDG_LIB_HOME

# Core Environment
export EDITOR='nvim'
export VISUAL='nvim'
export TERM='xterm-256color'

# Locale
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Security and Performance
umask 022
export TMPDIR="${TMPDIR:-/tmp}"

# Shell behavior
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# Zsh session directory (use XDG state directory)
export SHELL_SESSION_DIR="$XDG_STATE_HOME/zsh/sessions"
[[ ! -d "$SHELL_SESSION_DIR" ]] && mkdir -p "$SHELL_SESSION_DIR"

# Homebrew
export HOMEBREW_NO_ENV_HINTS=1
