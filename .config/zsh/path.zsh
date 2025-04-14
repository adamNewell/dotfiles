# =============================================================================
#                               Path Configuration
# =============================================================================

# System paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Local binary paths
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.gwctl" ]] && PATH="$PATH:$HOME/.gwctl"

# =============================================================================
#                               Homebrew Configuration
# =============================================================================

[[ -d "/opt/homebrew/bin" ]] && PATH="/opt/homebrew/bin:$PATH"
[[ -d "/opt/homebrew/sbin" ]] && PATH="/opt/homebrew/sbin:$PATH"

# =============================================================================
#                               Finalization
# =============================================================================

# Export final PATH
export PATH
