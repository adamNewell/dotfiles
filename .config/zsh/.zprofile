# =============================================================================
#                               Shell Session Configuration
# =============================================================================

# These settings must be in .zprofile as they are used by macOS's /etc/zshrc,
# which is sourced before .zshrc
export SHELL_SESSION_DIR=$XDG_STATE_HOME/zsh/sessions
export SHELL_SESSION_FILE=$SHELL_SESSION_DIR/$TERM_SESSION_ID

# =============================================================================
#                               Environment Configuration
# =============================================================================

# Source Homebrew environment if available
[[ -f "$XDG_CONFIG_HOME/homebrew/brew.env" ]] && source "$XDG_CONFIG_HOME/homebrew/brew.env"

# Export final PATH
export PATH

