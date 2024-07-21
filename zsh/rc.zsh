setopt INC_APPEND_HISTORY_TIME

source $HOME/.config/.env

source_if_exists () {
    if test -r "$1"; then
        source "$1"
    fi
}

for file in $DOTFILES/zsh/{path,exports,aliases,functions,extra}.zsh; do
    [ -r "$file" ] && [ -f "$file" ] && source_if_exists "$file";
done;
unset file;

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
autoload -Uz compinit && compinit

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
