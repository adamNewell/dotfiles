# =============================================================================
#                               PATH Configuration
# =============================================================================
# Centralized PATH management - all PATH modifications in one place

# Initialize with system defaults
PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Local user binaries (highest priority)
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"

# Homebrew - add common paths first, then use dynamic detection
# Add common Homebrew paths so we can find brew command
if [[ -d "/opt/homebrew/bin" ]]; then
    PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [[ -f "/usr/local/bin/brew" ]]; then
    PATH="/usr/local/bin:$PATH"
fi

# Now use dynamic detection to get the correct prefix
if command -v brew >/dev/null 2>&1; then
    local brew_prefix="$(brew --prefix)"
    # Only add if it's different from what we already added
    if [[ "${brew_prefix}" != "/opt/homebrew" ]] && [[ "${brew_prefix}" != "/usr/local" ]]; then
        if [[ -d "${brew_prefix}/bin" ]] && [[ ":$PATH:" != *":${brew_prefix}/bin:"* ]]; then
            PATH="${brew_prefix}/bin:${brew_prefix}/sbin:$PATH"
        fi
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