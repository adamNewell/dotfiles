# =============================================================================
#                               PATH Configuration
# =============================================================================
# Centralized PATH management - all PATH modifications in one place

# Initialize with system defaults
PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Local user binaries (highest priority)
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"

# Homebrew (macOS)
if [[ -d "/opt/homebrew" ]]; then
    PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [[ -d "/usr/local/Homebrew" ]]; then
    PATH="/usr/local/bin:$PATH"
fi

# Development tools (will be overridden by tool-specific configs if needed)
[[ -d "$HOME/.cargo/bin" ]] && PATH="$HOME/.cargo/bin:$PATH"
[[ -d "$HOME/.pyenv/bin" ]] && PATH="$HOME/.pyenv/bin:$PATH"

# Tool-specific paths
[[ -d "$HOME/.gwctl" ]] && PATH="$PATH:$HOME/.gwctl"

# Node.js global modules (if using npm global)
[[ -d "$HOME/.npm-global/bin" ]] && PATH="$HOME/.npm-global/bin:$PATH"

# Go binaries
[[ -d "$HOME/go/bin" ]] && PATH="$HOME/go/bin:$PATH"

# Export final PATH
export PATH