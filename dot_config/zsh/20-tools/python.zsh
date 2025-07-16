# =============================================================================
#                               Python/pyenv Configuration
# =============================================================================

# pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init - zsh)"
fi

# Python settings
export PYTHONDONTWRITEBYTECODE=1  # Prevent Python from writing .pyc files
export PYTHONUNBUFFERED=1         # Force Python to run in unbuffered mode
export PYTHONHISTFILE="$XDG_STATE_HOME/python/history"

# pip configuration
export PIP_CONFIG_FILE="$XDG_CONFIG_HOME/pip/pip.conf"
export PIP_LOG_FILE="$XDG_CACHE_HOME/pip/log"