# Per https://unix.stackexchange.com/a/654684

# No need to export anything here, as .zshenv is sourced for 
# _every_ shell (unless invoked with `zsh -f`).

# Assign these only if they don't have value yet. 
: ${XDG_CONFIG_HOME:=$HOME/.config}
: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_STATE_HOME:=$HOME/.local/state}
: ${XDG_DATA_HOME:=$HOME/.local/share}
: ${XDG_BIN_HOME:=$HOME/.local/bin}
: ${XDG_LIB_HOME:=$HOME/.local/lib}

# Set $ZDOTDIR here to be able to store your other Zsh dotfiles 
# outside of $HOME. 
ZDOTDIR=$XDG_CONFIG_HOME/zsh
