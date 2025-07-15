# =============================================================================
#                               Completion System
# =============================================================================
# Zsh completion configuration

# Add function paths for completions
fpath=("$ZDOTDIR/completions" "$ZDOTDIR/functions" $fpath)

# Initialize completion system
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

# Completion cache directory
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' complete-options true
zstyle ':completion:*' file-sort modification reverse
zstyle ':completion:*:*:*:*:*' menu select

# Completion styling
zstyle ':completion:*' menu select=2
zstyle ':completion:*' verbose yes
zstyle ':completion:*' descriptions format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for %d'
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# Completion options
setopt COMPLETE_IN_WORD          # Complete from both ends of a word
setopt ALWAYS_TO_END             # Move cursor to the end of a completed word
setopt PATH_DIRS                 # Perform path search even on command names with slashes
setopt AUTO_MENU                 # Show completion menu on a successive tab press
setopt AUTO_LIST                 # Automatically list choices on ambiguous completion