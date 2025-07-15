# =============================================================================
#                               Plugin Management (sheldon)
# =============================================================================

# Initialize completion system once
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

# Load plugins via sheldon
eval "$(sheldon source)"

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

# FZF options
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# thefuck initialization (loaded via plugin)
eval $(thefuck --alias)