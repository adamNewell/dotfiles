# =============================================================================
#                               Core Configuration
# =============================================================================

# Enable zsh profiling for performance analysis
zmodload zsh/zprof

# Performance optimizations
skip_global_compinit=1        # Skip the global compinit
DISABLE_AUTO_UPDATE=true      # Disable auto-updates for better startup time

# Security settings
umask 022                     # Set default permissions
TMOUT=1800                    # Auto logout after 30 minutes of inactivity
readonly TMOUT
export TMOUT

# Source environment variables if they exist
[[ -f "$HOME/.config/.env" ]] && source "$HOME/.config/.env"

# Helper function for sourcing files
source_if_exists () {
    if test -r "$1"; then
        source "$1"
    fi
}

# Helper function for logging
zsh_log() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[${timestamp}] $1" >&2
}

# =============================================================================
#                               Oh My Zsh Configuration
# =============================================================================

# Path to oh-my-zsh installation
export ZSH="$ZDOTDIR/ohmyzsh"

# Set custom plugins path (parent directory of plugins)
export ZSH_CUSTOM="$ZDOTDIR"

# Set theme (using oh-my-posh instead)
ZSH_THEME=""

# Oh My Zsh Settings
DISABLE_AUTO_UPDATE="true"              # Disable automatic updates
DISABLE_UPDATE_PROMPT="true"            # Disable update prompts
COMPLETION_WAITING_DOTS="true"          # Display dots while waiting for completion
DISABLE_UNTRACKED_FILES_DIRTY="true"    # Disable marking untracked files as dirty
HIST_STAMPS="yyyy-mm-dd"                # Date format for history

# Plugin Configuration
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20              # Maximum number of characters to suggest
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'          # Style for autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)   # Strategy for suggestions
ZSH_AUTOSUGGEST_USE_ASYNC=1                     # Use async mode for better performance

# Oh My Zsh Plugins
plugins=(
    # Built-in plugins
    git                 # Git integration and aliases
    docker              # Docker completion and aliases
    docker-compose      # Docker-compose completion and aliases
    npm                 # NPM completion and aliases
    node                # Node.js utilities
    macos               # macOS-specific commands
    brew                # Homebrew shortcuts
    command-not-found   # Suggest package to install if command not found
    colored-man-pages   # Add colors to man pages
    
    # External plugins
    zsh-autosuggestions      # Fish-like autosuggestions
    zsh-syntax-highlighting  # Syntax highlighting for commands
    history-substring-search # Fish-like history search
)

# Source Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# =============================================================================
#                               Shell Options
# =============================================================================

# Input/Output
setopt INTERACTIVE_COMMENTS    # Allow comments in interactive shell
setopt RM_STAR_WAIT            # Wait 10 seconds before executing rm *
setopt PRINT_EXIT_VALUE        # Print exit value if non-zero
setopt NO_CLOBBER              # Don't overwrite files with >
setopt NO_FLOW_CONTROL         # Disable start/stop characters in shell editor

# Job Control
setopt AUTO_RESUME             # Resume existing job rather than create new one
setopt LONG_LIST_JOBS          # List jobs in long format
setopt NOTIFY                  # Report status of background jobs immediately

# Error Handling
setopt ERR_RETURN              # Return from a function on error

# Expansion and Globbing
setopt NUMERIC_GLOB_SORT       # Sort filenames numerically when it makes sense
setopt MARK_DIRS               # Append a trailing '/' to all directory names
setopt GLOB_DOTS               # Include dotfiles in globbing

# Directory Navigation
setopt AUTO_CD                 # If command is a directory path, cd into it
setopt AUTO_PUSHD              # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS       # Don't push multiple copies of the same directory
setopt PUSHD_MINUS             # Exchanges the meanings of '+' and '-' when used with a number
setopt EXTENDED_GLOB           # Use extended globbing syntax

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
autoload -Uz compinit

# Only regenerate completion cache once per day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Completion Options
setopt COMPLETE_IN_WORD    # Complete from both ends of a word
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word
setopt PATH_DIRS           # Perform path search even on command names with slashes
setopt AUTO_MENU           # Show completion menu on a successive tab press
setopt AUTO_LIST           # Automatically list choices on ambiguous completion
setopt MENU_COMPLETE       # Auto select the first completion entry

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
autoload -U zmv
autoload -U promptinit && promptinit
autoload -U colors && colors

# Load completion menu selection
zmodload zsh/complist  # Required for menuselect keymap

# Enable vim mode
bindkey -v             # Enable vim mode
export KEYTIMEOUT=1    # Reduce mode switch delay

# Basic navigation
bindkey '^[[H' beginning-of-line               # Home: Go to beginning of line
bindkey '^[[F' end-of-line                     # End: Go to end of line
bindkey '^[[3~' delete-char                    # Delete: Delete character under cursor
bindkey '^H' backward-delete-char              # Backspace: Delete character before cursor
bindkey '^[[1;5C' forward-word                 # Ctrl+Right Arrow: Move forward one word
bindkey '^[[1;5D' backward-word                # Ctrl+Left Arrow: Move backward one word
bindkey '^?' backward-delete-char              # Delete: Delete character before cursor
bindkey '^[[Z' reverse-menu-complete           # Shift+Tab: Go to previous completion item
bindkey '^U' backward-kill-line                # Ctrl+U: Delete from cursor to start of line
bindkey '^Y' yank                              # Ctrl+Y: Paste previously deleted text
bindkey '^W' backward-kill-word                # Ctrl+W: Delete word before cursor
bindkey '^ ' autosuggest-accept                # Ctrl+Space: Accept autosuggestion

# Edit command in editor
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line               # Ctrl+X,Ctrl+E: Edit command in editor

# Additional useful bindings
bindkey '^R' history-incremental-search-backward    # Ctrl+R: Search history backward
bindkey '^S' history-incremental-search-forward     # Ctrl+S: Search history forward
bindkey '^A' beginning-of-line                      # Ctrl+A: Go to beginning of line
bindkey '^E' end-of-line                            # Ctrl+E: Go to end of line
bindkey '^D' delete-char-or-list                    # Ctrl+D: Delete char or show completion list
bindkey '^K' kill-line                              # Ctrl+K: Delete from cursor to end of line
bindkey '^T' transpose-chars                        # Ctrl+T: Swap current char with previous

# =============================================================================
#                               External Tools
# =============================================================================

# Initialize oh-my-posh if available
if command -v oh-my-posh >/dev/null 2>&1; then    
    local theme_path="$XDG_DATA_HOME/oh-my-posh/themes/adamnewell.toml"
    [[ -f "$theme_path" ]] && eval "$(oh-my-posh init zsh --config $theme_path)"
fi

# Initialize SSH agent
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    zsh_log "Starting new SSH agent"
    eval $(ssh-agent -s -t 3600) > /dev/null  # 1-hour timeout
    trap 'test -n "$SSH_AGENT_PID" && eval `/usr/bin/ssh-agent -k`' 0  # Kill agent on exit
fi

# Add SSH keys with timeout
if [[ -n "$SSH_AGENT_PID" ]]; then
    # Check if agent is still running
    kill -0 $SSH_AGENT_PID 2>/dev/null || {
        zsh_log "SSH agent died, restarting"
        eval $(ssh-agent -s -t 3600) > /dev/null
    }

    # Add keys with timeout
    for key in ~/.ssh/*; do
        if [[ -f "$key" && "$key" != *.pub && "$key" != *known_hosts* && "$key" != *config* ]]; then
            if ! ssh-add -l | grep -q "$(ssh-keygen -lf "$key" | awk '{print $2}')" 2>/dev/null; then
                zsh_log "Adding SSH key: $key"
                ssh-add -t 3600 "$key" 2>/dev/null || zsh_log "Failed to add key: $key"
            fi
        fi
    done
fi

# Initialize additional tools if available
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Source FZF configuration
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh

# =============================================================================
#                               Source Modules
# =============================================================================

# Source modular configurations
for config_file in path exports tools aliases functions extra local; do
    if [[ -f "$ZDOTDIR/$config_file.zsh" ]]; then
        source_if_exists "$ZDOTDIR/$config_file.zsh"
    elif [[ -d "$ZDOTDIR/$config_file" ]]; then
        for file in "$ZDOTDIR/$config_file"/*.zsh; do
            source_if_exists "$file"
        done
    fi
done

# =============================================================================
#                               Hooks & Callbacks
# =============================================================================

# Reload aliases if changed
precmd() {
    local aliases_file="$ZDOTDIR/aliases.zsh"
    if [[ -f "$aliases_file" ]]; then
        local current_mtime
        current_mtime=$(stat -f "%m" "$aliases_file" 2>/dev/null) || return
        if [[ ! -v ALIASES_MTIME ]] || [[ "$current_mtime" != "$ALIASES_MTIME" ]]; then
            zsh_log "Reloading aliases file"
            source "$aliases_file"
            ALIASES_MTIME="$current_mtime"
        fi
    fi
}
