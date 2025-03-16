# =============================================================================
#                               XDG Base Directory
# =============================================================================

# Export XDG vars without values - they're set in .zshenv
export XDG_CONFIG_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_BIN_HOME XDG_LIB_HOME 

# =============================================================================
#                               Core Environment
# =============================================================================

# Editor and terminal settings
export EDITOR=vim VISUAL=vim
export TERM="xterm-256color"

# Locale settings
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# History settings
export HISTFILESIZE="${HISTSIZE}"
export LESSHISTFILE=$XDG_STATE_HOME/less/history

# =============================================================================
#                               Tool Configuration
# =============================================================================

# Homebrew settings
export HOMEBREW_NO_ENV_HINTS=1

# Man pages and less
export LESS_TERMCAP_md="${yellow}"  # Highlight section titles in manual pages
export MANPAGER='less -X'           # Don't clear screen after quitting manual page

# Colors and formatting
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# =============================================================================
#                               FZF Configuration
# =============================================================================

# Core FZF settings
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# FZF preview settings
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# =============================================================================
#                               Other Tools
# =============================================================================

# Bat theme
export BAT_THEME="Monokai Extended Bright"

# Ripgrep configuration
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# MySQL client paths
export LDFLAGS="-L/opt/homebrew/opt/mysql-client/lib"
export CPPFLAGS="-I/opt/homebrew/opt/mysql-client/include"

# Bash completion (if needed)
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# Oh My Zsh update frequency
export UPDATE_ZSH_DAYS=7

# Cleanup
unset GREP_OPTIONS  # Remove deprecated options
