# =============================================================================
#                               PATH Configuration
# =============================================================================
# Centralized PATH management - all PATH modifications in one place

# Initialize with system defaults
PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Local user binaries (highest priority)
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"

# Homebrew - use dynamic detection instead of hardcoded paths
if command -v brew >/dev/null 2>&1; then
    # Get Homebrew's actual path and add to PATH if not already there
    local brew_prefix="$(brew --prefix)"
    if [[ -d "${brew_prefix}/bin" ]] && [[ ":$PATH:" != *":${brew_prefix}/bin:"* ]]; then
        PATH="${brew_prefix}/bin:${brew_prefix}/sbin:$PATH"
    fi
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