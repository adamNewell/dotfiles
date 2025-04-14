# =============================================================================
#                               Configuration Shortcuts
# =============================================================================

# Quick access to configuration files
alias sshconfig="nvim ~/.ssh/config"
alias zshconfig="nvim ~/.config/zsh/.zshrc"
alias dotconfig="vim $DOTFILES"
alias zsource="source $XDG_CONFIG_HOME/zsh/.zshrc"

# =============================================================================
#                               Tool Replacements
# =============================================================================

# Use modern alternatives
alias vim="nvim"
alias cd="z"
alias ls="eza --long --icons --no-quotes --all --group-directories-first --octal-permissions --no-user --git"
alias ll="ls"

# =============================================================================
#                               Docker Commands
# =============================================================================

# Update all Docker images
alias docker-images-update="docker images | grep -v REPOSITORY | awk '{print $1}' | xargs -L1 docker pull"

