# =============================================================================
#                               History Configuration
# =============================================================================
# Zsh history settings

# History file location and size
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=1000000
export SAVEHIST=1000000
export HISTCONTROL='ignoreboth'

# Create history directory if it doesn't exist
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"

# History options
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks from each command line
setopt HIST_VERIFY               # Do not execute immediately upon history expansion
setopt INC_APPEND_HISTORY_TIME   # Write to the history file immediately, not when the shell exits
unsetopt SHARE_HISTORY           # Don't share history between different shells