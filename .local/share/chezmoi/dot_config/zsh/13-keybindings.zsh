# =============================================================================
#                               Key Bindings
# =============================================================================
# Custom key bindings and vim mode configuration

# Load additional ZSH functionality
autoload -U zmv promptinit colors
promptinit
colors

# Load completion menu selection
zmodload zsh/complist  # Required for menuselect keymap

# Enable vim mode
bindkey -v             # Enable vim mode
export KEYTIMEOUT=1    # Reduce mode switch delay

# Custom key bindings
bindkey '^[[1;5C' forward-word                 # Ctrl+Right Arrow: Move forward one word
bindkey '^[[1;5D' backward-word                # Ctrl+Left Arrow: Move backward one word
bindkey '^[[Z' reverse-menu-complete           # Shift+Tab: Go to previous completion item
bindkey '^ ' autosuggest-accept                # Ctrl+Space: Accept autosuggestion

# Edit command in editor
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line               # Ctrl+X,Ctrl+E: Edit command in editor