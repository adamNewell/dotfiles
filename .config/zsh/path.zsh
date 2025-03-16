# =============================================================================
#                               System Paths
# =============================================================================

# Add system paths first (will be prepended to by tool-specific paths)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Add local binary paths
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.gwctl" ]] && PATH="$PATH:$HOME/.gwctl"
export GWCTL_CONFIG_DIR="$HOME/.gwctl/configs"

# =============================================================================
#                               Homebrew Configuration
# =============================================================================

# Initialize Homebrew if available
if BREW_PATH=$(command -v brew); then
    eval "$($BREW_PATH shellenv)"
    
    # Cache brew prefix for faster loading
    if [[ ! -f "$ZDOTDIR/.brew_prefix" ]]; then
        $BREW_PATH --prefix > "$ZDOTDIR/.brew_prefix"
    fi
    BREW_PREFIX=$(<"$ZDOTDIR/.brew_prefix")
    
    # Add Homebrew-installed tools to PATH
    if [[ -d "$BREW_PREFIX/opt/coreutils/libexec/gnubin" ]]; then
        PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
    fi
    
    if [[ -d "$BREW_PREFIX/opt/e2fsprogs/bin" ]]; then
        PATH="$BREW_PREFIX/opt/e2fsprogs/bin:$BREW_PREFIX/opt/e2fsprogs/sbin:$PATH"
    fi
    
    [[ -d "$BREW_PREFIX/opt/mysql-client/bin" ]] && PATH="$BREW_PREFIX/opt/mysql-client/bin:$PATH"
fi

# =============================================================================
#                               Finalization
# =============================================================================

# Export final PATH
export PATH
