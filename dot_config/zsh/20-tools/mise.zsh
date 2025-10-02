# =============================================================================
#                               Mise Configuration
# =============================================================================
# Mise version manager for runtime environments

# Add mise bin directory to PATH first
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Only proceed if mise is available after PATH update
if ! command -v mise >/dev/null 2>&1; then
    return 0
fi

# Activate mise for current shell
eval "$(mise activate zsh)"

# Set up completion for mise
if [[ -n "${BASH_COMPLETION_USER_DIR:-}" ]]; then
    mise completion zsh > "${BASH_COMPLETION_USER_DIR}/mise"
fi

# Tool-specific environment variables
export MISE_NODE_DEFAULT_PACKAGES_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/mise/default-packages-node"
export MISE_PYTHON_DEFAULT_PACKAGES_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/mise/default-packages-python"

# Use experimental features if desired
export MISE_EXPERIMENTAL=1

# Configure logging
export MISE_LOG_LEVEL="${MISE_LOG_LEVEL:-info}"
export MISE_LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/mise/mise.log"

# Create log directory if it doesn't exist
[[ ! -d "$(dirname "${MISE_LOG_FILE}")" ]] && mkdir -p "$(dirname "${MISE_LOG_FILE}")"

# Aliases for common mise operations
alias mi="mise"
alias mii="mise install"
alias miu="mise use"
alias mil="mise list"
alias mils="mise ls"
alias mir="mise run"
alias mix="mise exec"
alias mig="mise global"
alias mil="mise local"
alias mish="mise shell"
alias miw="mise which"
alias miwh="mise where"
alias mip="mise plugins"
alias mic="mise current"
alias mie="mise env"
alias mis="mise settings"
alias miv="mise version"
alias mih="mise help"
