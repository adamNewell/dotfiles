# =============================================================================
#                               Configuration Shortcuts
# =============================================================================

# Quick access to common configuration files
alias sshconfig="vim $HOME/.ssh/config"
alias vimconfig="vim $DOTFILES/vim/.vimrc"
alias zshconfig="vim $XDG_CONFIG_HOME/zsh/.zshrc"
alias dotconfig="vim $DOTFILES"

# Shell reload
alias zsource="source $XDG_CONFIG_HOME/zsh/.zshrc"

# =============================================================================
#                               Tool Replacements
# =============================================================================

# Use neovim instead of vim
alias vim="nvim"

# Enhanced ls with eza
alias eza="eza --long --icons --no-quotes --all --group-directories-first --octal-permissions --no-user --git"
alias ll="eza"

# Use zoxide instead of cd
alias cd="z"

# =============================================================================
#                               Git Shortcuts
# =============================================================================

alias gst="git status"
alias gp="git pull"
alias gd="git diff"

# =============================================================================
#                               Docker Commands
# =============================================================================

# Update all Docker images
alias docker-images-update="docker images | grep -v REPOSITORY | awk '{print $1}' | xargs -L1 docker pull"

