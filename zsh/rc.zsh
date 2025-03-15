setopt INC_APPEND_HISTORY_TIME

source $HOME/.config/.env

source_if_exists () {
    if test -r "$1"; then
        source "$1"
    fi
}

fpath=($DOTFILES/zsh/completions $fpath)
autoload -Uz compinit && compinit

# Source either direct .zsh files or all .zsh files in directories
for path in $DOTFILES/zsh/{path,exports,aliases,functions,extra,local}; do
    if [[ -f "$path.zsh" ]]; then
        source_if_exists "$path.zsh"
    elif [[ -d "$path" ]]; then
        for file in "$path"/*.zsh; do
            source_if_exists "$file"
        done
    fi
done
unset path file

# Per https://unix.stackexchange.com/a/654684
# HISTFILE is used by interactive shells only. Plus, 
# non-interactive shells & external commands don't need this var. 
# Hence, we put it and all HIST related variables in your .zshrc file, 
# since that's sourced for each interactive shell, and don't export it.
HISTFILE=$XDG_STATE_HOME/zsh/history
HISTSIZE=32768
HISTCONTROL='ignoreboth';
SAVEHIST=$HISTSIZE

precmd() {
    source $DOTFILES/zsh/aliases.zsh
}

# This removes the 'Last login...' line from iTerm2
#touch ~/.hushlogin

# ZSH Completion
zstyle ':completion:*' menu select=2
zstyle ':completion:*' verbose yes
zstyle ':completion:*' descriptions format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for %d'
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

autoload -U zmv
autoload -U promptinit && promptinit
autoload -U colors && colors

if test -z ${ZSH_HIGHLIGHT_DIR+x}; then
else
    source $ZSH_HIGHLIGHT_DIR/zsh-syntax-highlighting.zsh
fi

eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/adamnewell.toml)"

# Set up fzf keybindings and fuzzy completion
eval "$(fzf --zsh)"

eval $(thefuck --alias)
eval "$(zoxide init zsh)"

source $DOTFILES/include/fzf-git.sh/fzf-git.sh

