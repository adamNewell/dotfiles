# =============================================================================
#                               Plugin Management (sheldon)
# =============================================================================

# Initialize completion system once
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

# Load plugins via sheldon (only if available)
if command -v sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
else
    echo "Warning: sheldon not found - plugins not loaded" >&2
fi

# =============================================================================
#                               Plugin Settings
# =============================================================================

# Autosuggestions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_USE_ASYNC=0
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
ZSH_AUTOSUGGEST_COMPLETION_IGNORE="git *"

# thefuck initialization moved to 20-tools/misc.zsh for consistency
