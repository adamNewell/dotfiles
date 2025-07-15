# =============================================================================
#                               Miscellaneous Tools
# =============================================================================

# Initialize common command-line tools

# zoxide (smart cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Homebrew
command -v brew >/dev/null 2>&1 && eval "$(brew shellenv)"

# fzf (fuzzy finder) - load XDG config
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
[[ -f "$XDG_CONFIG_HOME/fzf/fzf.zsh" ]] && source "$XDG_CONFIG_HOME/fzf/fzf.zsh"

# ripgrep - use XDG config
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# pyenv
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv virtualenv-init -)"

# oh-my-posh prompt
if command -v oh-my-posh >/dev/null 2>&1; then    
    local theme_path="$XDG_DATA_HOME/oh-my-posh/themes/adamnewell.toml"
    [[ -f "$theme_path" ]] && eval "$(oh-my-posh init zsh --config $theme_path)"
fi

# thefuck command correction
command -v thefuck >/dev/null 2>&1 && eval $(thefuck --alias)