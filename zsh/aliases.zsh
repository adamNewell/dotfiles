alias sshconfig="vim $HOME/.ssh/config"
alias vimconfig="vim $DOTFILES/vim/.vimrc"
alias zshconfig="vim $HOME/.zshrc"
alias zsource="source $HOME/.zshrc"
alias ohmyzsh="vim $HOME/.oh-my-zsh"
alias vim="nvim"
alias docker-images-update="docker images | grep -v REPOSITORY | awk '{print $1}' | xargs -L1 docker pull"
#alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias eza="eza --long --icons --no-quotes --all --group-directories-first --octal-permissions --no-user --git"
alias ll="eza"
alias cd="z"

