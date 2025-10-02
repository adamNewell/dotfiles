# =============================================================================
#                               Shell Options
# =============================================================================
# Zsh behavior and feature configuration

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
setopt NO_NOMATCH                # Don't print error on no glob matches
setopt NO_CASE_GLOB              # Case insensitive globbing for better performance

# Directory Navigation
setopt AUTO_CD                   # If command is a directory path, cd into it
setopt AUTO_PUSHD                # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS         # Don't push multiple copies of the same directory
setopt PUSHD_MINUS               # Exchanges the meanings of '+' and '-' when used with a number
setopt EXTENDED_GLOB             # Use extended globbing syntax

# Performance optimizations
skip_global_compinit=1           # Skip the global compinit
DISABLE_AUTO_UPDATE=true         # Disable auto-updates for better startup time
