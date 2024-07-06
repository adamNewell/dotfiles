# Make vim the default editor.
export EDITOR='vim';

DISABLE_UPDATE_PROMPT="true"

# Enable persistent REPL history for `node`.
NODE_REPL_HISTORY_FILE=~/.node_history;
# Allow 32³ entries; the default is 1000.
NODE_REPL_HISTORY_SIZE='32768';

# Increase Bash history size. Allow 32³ entries; the default is 500.
export HISTSIZE='32768';
export HISTFILESIZE="${HISTSIZE}";
# Omit duplicates and commands that begin with a space from history.
export HISTCONTROL='ignoreboth';

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';

# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${yellow}";

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X';

# Always enable colored `grep` output.
export GREP_OPTIONS='--color=auto';

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh --no-use"

# Path to your oh-my-zsh installation.
export ZSH="/Users/$USER/.oh-my-zsh"
export TERM="xterm-256color"
export VISUAL="vim"

export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

export UPDATE_ZSH_DAYS=7

export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

export FZF_DEFAULT_COMMAND="fd —-hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd —-type=d hidden --strip-cwd-prefix --exclude .git"

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS=--preview 'eza --tree --color=always {} | head -200'"

export BAT_THEME="Monokai Extended Bright"

