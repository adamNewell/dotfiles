# =============================================================================
#                               Source Local Files
# =============================================================================

# Source environment variables
[[ -f "$HOME/.config/.env" ]] && source "$HOME/.config/.env"

# Initialize zoxide
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Initialize Homebrew if available
command -v brew >/dev/null 2>&1 && eval "$(brew shellenv)"

# Initialize fzf if available
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"

# Initialize pyenv
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv virtualenv-init -)"

# Helper function for sourcing files
source_if_exists() { [[ -f "$1" && -r "$1" ]] && source "$1" }

# Source modular configurations
for config_file in plugins path exports tools functions aliases extra local; do
    if [[ -f "$ZDOTDIR/$config_file.zsh" ]]; then
        source_if_exists "$ZDOTDIR/$config_file.zsh"
    elif [[ -d "$ZDOTDIR/$config_file" ]]; then
        for file in "$ZDOTDIR/$config_file"/*.zsh(N); do
            source_if_exists "$file"
        done
    fi
done

# =============================================================================
#                               Core Configuration
# =============================================================================

# Initialize oh-my-posh if available
if command -v oh-my-posh >/dev/null 2>&1; then    
    local theme_path="$XDG_DATA_HOME/oh-my-posh/themes/adamnewell.toml"
    [[ -f "$theme_path" ]] && eval "$(oh-my-posh init zsh --config $theme_path)"
fi

# Initialize SSH agent and add keys
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval $(ssh-agent -s -t 3600) > /dev/null
    trap 'test -n "$SSH_AGENT_PID" && eval `/usr/bin/ssh-agent -k`' 0
    for key in ~/.ssh/*; do
        case "$key" in
            *.pub|*known_hosts*|*config*) continue ;;
            *)
                [[ -f "$key" ]] && ssh-add -t 3600 "$key" 2>/dev/null || true
                ;;
        esac
    done
fi

# Performance optimizations
skip_global_compinit=1           # Skip the global compinit
DISABLE_AUTO_UPDATE=true         # Disable auto-updates for better startup time

# Disable globbing for better performance
setopt NO_NOMATCH                # Don't print error on no glob matches
setopt NO_CASE_GLOB              # Case insensitive globbing for better performance

# Compile zcompdump if needed (with lock file to prevent duplicate runs)
{
    zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
    [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]] && \
        zcompile "$zcompdump" >/dev/null 2>&1
} &!

# Security settings
umask 022
readonly TMOUT
export TMOUT

# =============================================================================
#                               Shell Options
# =============================================================================

# Performance related options
setopt HASH_CMDS                 # Hash command locations for faster execution
setopt HASH_DIRS                 # Hash directories containing commands
setopt NO_FLOW_CONTROL           # Disable start/stop characters for better performance
setopt NO_BEEP                   # Disable beeping for better performance
setopt NO_HIST_BEEP              # Disable beeping for history events

# Input/Output
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shell
setopt RM_STAR_WAIT              # Wait 10 seconds before executing rm *
setopt NO_CLOBBER                # Don't overwrite files with >

# Job Control
setopt AUTO_RESUME               # Resume existing job rather than create new one
setopt LONG_LIST_JOBS            # List jobs in long format
setopt NOTIFY                    # Report status of background jobs immediately

# Error Handling
setopt ERR_RETURN                # Return from a function on error

# Expansion and Globbing
setopt NUMERIC_GLOB_SORT         # Sort filenames numerically when it makes sense
setopt MARK_DIRS                 # Append a trailing '/' to all directory names
setopt GLOB_DOTS                 # Include dotfiles in globbing

# Directory Navigation
setopt AUTO_CD                   # If command is a directory path, cd into it
setopt AUTO_PUSHD                # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS         # Don't push multiple copies of the same directory
setopt PUSHD_MINUS               # Exchanges the meanings of '+' and '-' when used with a number
setopt EXTENDED_GLOB             # Use extended globbing syntax

# =============================================================================
#                               History Configuration
# =============================================================================

HISTFILE=$XDG_STATE_HOME/zsh/history
HISTSIZE=1000000
SAVEHIST=1000000
HISTCONTROL='ignoreboth'

# Create history directory if it doesn't exist
[[ -d $XDG_STATE_HOME/zsh ]] || mkdir -p $XDG_STATE_HOME/zsh

# History Options
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

# =============================================================================
#                               Completion System
# =============================================================================

# Initialize completion system
fpath=("$ZDOTDIR/completions" "$ZDOTDIR/functions" $fpath)

# Completion cache directory
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' complete-options true
zstyle ':completion:*' file-sort modification reverse
zstyle ':completion:*:*:*:*:*' menu select

# Completion Options
setopt COMPLETE_IN_WORD          # Complete from both ends of a word
setopt ALWAYS_TO_END             # Move cursor to the end of a completed word
setopt PATH_DIRS                 # Perform path search even on command names with slashes
setopt AUTO_MENU                 # Show completion menu on a successive tab press
setopt AUTO_LIST                 # Automatically list choices on ambiguous completion

# Completion Styling
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

# =============================================================================
#                               Key Bindings
# =============================================================================

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
