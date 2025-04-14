# =============================================================================
#                               Plugin Management (zinit)
# =============================================================================

# Initialize zinit
typeset -gA ZINIT
ZINIT[HOME_DIR]="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"
ZINIT[BIN_DIR]="${ZINIT[HOME_DIR]}/zinit.git"

# Install zinit if not present
if [[ ! -f "${ZINIT[BIN_DIR]}/zinit.zsh" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "${ZINIT[HOME_DIR]}" && command chmod g-rwX "${ZINIT[HOME_DIR]}"
    command git clone https://github.com/zdharma-continuum/zinit "${ZINIT[BIN_DIR]}" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "${ZINIT[BIN_DIR]}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# =============================================================================
#                               Plugin Configuration
# =============================================================================

# Initialize completion system once
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

# Core plugins (load first)
zinit light-mode for \
    zsh-users/zsh-completions

# Autosuggestions
zinit light-mode for \
    atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

# External tools
zinit as"program" from"gh-r" for \
    @junegunn/fzf

zinit light-mode for \
    atload"eval \$(thefuck --alias)" \
    laggardkernel/zsh-thefuck

# Essential Oh My Zsh plugins (minimal set)
zinit light-mode for \
    OMZL::git.zsh \
    OMZP::git \
    OMZL::history.zsh \
    OMZL::key-bindings.zsh \
    OMZL::completion.zsh \
    OMZP::docker \
    OMZP::docker-compose

# Syntax highlighting (load last)
zinit light-mode for \
    zsh-users/zsh-syntax-highlighting

# =============================================================================
#                               Plugin Settings
# =============================================================================

# Autosuggestions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_USE_ASYNC=0
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
ZSH_AUTOSUGGEST_COMPLETION_IGNORE="git *"

# FZF options
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# Debug information
print -P "%F{green}Zinit configuration loaded successfully%f"