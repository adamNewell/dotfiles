#!/bin/bash
# Universal dotfiles installer and environment setup
# Supports macOS, Linux, and Windows (WSL)
# This script will automatically switch to zsh if not already running in it

# Early check for zsh - if we're in bash and being piped, save and re-execute
if [[ -n "${BASH_VERSION:-}" ]] && [[ -z "${ZSH_VERSION:-}" ]] && [[ ! -f "$0" ]]; then
    # We're being piped and running in bash
    temp_script="/tmp/dotfiles_setup_$$.sh"
    cat > "$temp_script"
    chmod +x "$temp_script"
    # Re-execute with zsh (will install if needed)
    exec bash -c "
        if ! command -v zsh >/dev/null 2>&1; then
            echo 'Installing zsh first...'
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update -qq && sudo apt-get install -y zsh
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y zsh
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm zsh
            elif command -v brew >/dev/null 2>&1; then
                brew install zsh
            fi
        fi
        exec zsh '$temp_script' $*
    " -- "$@"
fi
# 
# Features:
# - Automatic platform detection and package manager selection
# - ZSH-only configuration (no bash support)
# - Homebrew installation and management
# - Essential tool installation (git, curl, zsh, stow, etc.)
# - Modern CLI tools (ripgrep, fd, bat, eza, fzf, etc.)
# - Shell environment setup (zsh as default)
# - Chezmoi dotfile management
# - Comprehensive error handling and logging
#
# Usage: curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash

# Don't use set -e - we handle errors explicitly with return codes
set -o pipefail

# Configuration
readonly REPO_URL="https://github.com/adamNewell/dotfiles.git"
readonly SCRIPT_VERSION="2.1.0"
readonly CHECKPOINT_FILE="${HOME}/.dotfiles_setup_checkpoints"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Logging functions
info() { echo -e "${BLUE}ℹ️  $1${NC}" || true; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}" >&2; }
debug() { if [[ "${DEBUG:-}" == "1" ]]; then echo -e "${PURPLE}🐛 $1${NC}" >&2; fi; }
step() { echo -e "${CYAN}▶️  $1${NC}"; }

# Global variables
DETECTED_OS=""
DETECTED_ARCH=""
PACKAGE_MANAGER=""
INSTALL_MODE="full"
SKIP_PACKAGES=""
SKIP_MODERN_TOOLS=""

# Checkpoint management functions
checkpoint_completed() {
    local checkpoint="$1"
    grep -q "^${checkpoint}$" "${CHECKPOINT_FILE}" 2>/dev/null
}

mark_checkpoint() {
    local checkpoint="$1"
    echo "${checkpoint}" >> "${CHECKPOINT_FILE}"
    debug "Checkpoint marked: ${checkpoint}"
}

skip_if_completed() {
    local checkpoint="$1"
    local description="$2"

    if checkpoint_completed "${checkpoint}"; then
        info "Skipping ${description} (already completed)"
        return 0  # true - should skip
    fi
    return 1  # false - should not skip
}

reset_checkpoints() {
    rm -f "${CHECKPOINT_FILE}"
    info "Installation checkpoints reset"
}

# Retry logic for network operations
retry_command() {
    local max_attempts="${1}"
    local delay="${2}"
    shift 2
    local cmd=("$@")
    local attempt=1

    while (( attempt <= max_attempts )); do
        if "${cmd[@]}"; then
            return 0
        fi

        if (( attempt < max_attempts )); then
            warn "Command failed (attempt ${attempt}/${max_attempts}), retrying in ${delay}s..."
            sleep "${delay}"
        fi
        ((attempt++))
    done

    error "Command failed after ${max_attempts} attempts: ${cmd[*]}"
    return 1
}

# Update PATH for current session
update_path() {
    # Add common installation directories to PATH
    local new_paths=(
        "${HOME}/.local/bin"
        "/usr/local/bin"
        "/opt/homebrew/bin"
        "${HOME}/.cargo/bin"
    )

    for path_dir in "${new_paths[@]}"; do
        if [[ -d "${path_dir}" ]] && [[ ":${PATH}:" != *":${path_dir}:"* ]]; then
            export PATH="${path_dir}:${PATH}"
            debug "Added to PATH: ${path_dir}"
        fi
    done

    # Source Homebrew shellenv if available
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
    elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
    fi
}

# Cleanup function
cleanup() {
    local exit_code=$?
    debug "Cleaning up temporary files..."
    rm -f /tmp/dotfiles_setup_* /tmp/Brewfile /tmp/mise_install_* /tmp/homebrew_install_*

    if [[ ${exit_code} -ne 0 ]]; then
        error "Installation failed with exit code ${exit_code}"
        echo
        warn "To resume installation, simply re-run the setup script"
        info "To start fresh: rm ${CHECKPOINT_FILE} && re-run setup"
        echo
        info "For help, visit: https://github.com/adamNewell/dotfiles/issues"
    fi
    exit ${exit_code}
}

# Set up error handling
trap cleanup EXIT

# Usage information
show_usage() {
    cat << 'EOF'
Universal Dotfiles Setup Script

USAGE:
    curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash
    
    # Or with options:
    curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash -s -- [OPTIONS]

OPTIONS:
    --minimal           Install only essential tools (no development packages)
    --skip-packages     Skip package installation entirely
    --skip-modern-tools Skip installation of modern CLI tools
    --debug            Enable debug output
    --help             Show this help message

EXAMPLES:
    # Full installation
    curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash
    
    # Minimal installation
    curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash -s -- --minimal
    
    # Skip packages (config only)
    curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash -s -- --skip-packages

SUPPORTED PLATFORMS:
    - macOS (Intel and Apple Silicon)
    - Linux (Ubuntu, Debian, Fedora, Arch Linux)
    - Windows (WSL2)

For more information, visit: https://github.com/adamNewell/dotfiles
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --minimal)
                INSTALL_MODE="minimal"
                export DOTFILES_MINIMAL=true
                shift
                ;;
            --skip-packages)
                SKIP_PACKAGES="true"
                shift
                ;;
            --skip-modern-tools)
                SKIP_MODERN_TOOLS="true"
                shift
                ;;
            --debug)
                export DEBUG=1
                shift
                ;;
            --help|-h)
                show_usage
                return 0
                ;;
            *)
                warn "Unknown option: $1"
                show_usage
                return 1
                ;;
        esac
    done
}

# Platform detection
detect_platform() {
    step "Detecting platform..."
    
    local os_name
    local arch
    os_name="$(uname -s | tr '[:upper:]' '[:lower:]')"
    arch="$(uname -m)"
    
    # Normalize OS name
    case "${os_name}" in
        darwin) DETECTED_OS="macos" ;;
        linux) DETECTED_OS="linux" ;;
        mingw*|msys*|cygwin*) DETECTED_OS="windows" ;;
        *)
            error "Unsupported operating system: ${os_name}"
            return 1
            ;;
    esac
    
    # Normalize architecture
    case "${arch}" in
        x86_64|amd64) DETECTED_ARCH="amd64" ;;
        aarch64|arm64) DETECTED_ARCH="arm64" ;;
        armv7l) DETECTED_ARCH="arm" ;;
        *)
            warn "Unknown architecture: ${arch}, assuming amd64"
            DETECTED_ARCH="amd64"
            ;;
    esac
    
    info "Detected: ${DETECTED_OS} (${DETECTED_ARCH})"
    export DOTFILES_OS="${DETECTED_OS}"
    export DOTFILES_ARCH="${DETECTED_ARCH}"
}

# Package manager detection
detect_package_manager() {
    case "${DETECTED_OS}" in
        macos)
            # Use which instead of command -v to avoid exit issues
            if which brew >/dev/null 2>&1; then
                PACKAGE_MANAGER="brew"
            else
                PACKAGE_MANAGER="homebrew_install_needed"
            fi
            ;;
        linux)
            if which apt-get >/dev/null 2>&1; then
                PACKAGE_MANAGER="apt"
            elif which dnf >/dev/null 2>&1; then
                PACKAGE_MANAGER="dnf"
            elif which pacman >/dev/null 2>&1; then
                PACKAGE_MANAGER="pacman"
            elif which zypper >/dev/null 2>&1; then
                PACKAGE_MANAGER="zypper"
            else
                error "No supported package manager found"
                return 1
            fi
            ;;
        windows)
            if which winget >/dev/null 2>&1; then
                PACKAGE_MANAGER="winget"
            elif which scoop >/dev/null 2>&1; then
                PACKAGE_MANAGER="scoop"
            else
                warn "No Windows package manager found, will install via external downloads"
                PACKAGE_MANAGER="none"
            fi
            ;;
    esac
    
    debug "Package manager: ${PACKAGE_MANAGER}"
    # Comment out the echo line to prevent exit
    # echo "Successfully detected package manager: ${PACKAGE_MANAGER}"
}

# Ensure zsh is installed and set as default shell
ensure_zsh() {
    step "Ensuring zsh is installed and configured as default shell..."
    
    # Check if zsh is installed
    if ! command -v zsh >/dev/null 2>&1; then
        info "Installing zsh..."
        case "${PACKAGE_MANAGER}" in
            brew)
                brew install zsh
                ;;
            apt)
                sudo apt-get update -qq
                sudo apt-get install -y zsh
                ;;
            dnf)
                sudo dnf install -y zsh
                ;;
            pacman)
                sudo pacman -S --noconfirm zsh
                ;;
            *)
                error "Cannot install zsh with package manager: ${PACKAGE_MANAGER}"
                return 1
                ;;
        esac
    fi

    # Verify zsh installation
    if ! command -v zsh >/dev/null 2>&1; then
        error "Failed to install zsh. Cannot proceed."
        return 1
    fi
    
    local zsh_path
    zsh_path="$(command -v zsh)"
    
    # Add zsh to /etc/shells if not present
    if ! grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
        info "Adding zsh to /etc/shells..."
        echo "${zsh_path}" | sudo tee -a /etc/shells >/dev/null
    fi
    
    # Check current shell (cross-platform)
    local current_shell
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS: use dscl
        current_shell=$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}' 2>/dev/null || echo "$SHELL")
    else
        # Linux: use getent if available, otherwise fallback to /etc/passwd
        if command -v getent >/dev/null 2>&1; then
            current_shell=$(getent passwd "$USER" | cut -d: -f7 2>/dev/null || echo "$SHELL")
        else
            current_shell=$(grep "^$USER:" /etc/passwd | cut -d: -f7 2>/dev/null || echo "$SHELL")
        fi
    fi
    
    if [[ "$current_shell" != "$zsh_path" ]]; then
        info "Setting zsh as default shell..."
        if command -v chsh >/dev/null 2>&1; then
            chsh -s "${zsh_path}"
        else
            sudo usermod -s "${zsh_path}" "$USER"
        fi
        warn "Shell changed to zsh. You'll need to log out and back in for the change to take effect."
        warn "Or run: exec zsh"
    else
        success "zsh is already the default shell"
    fi
    
    # At this point we should already be in zsh due to early re-execution
    if [[ -n "${BASH_VERSION:-}" ]]; then
        error "Still running in bash after re-execution attempt. Something went wrong."
        return 1
    fi
}

# Install prerequisites
install_prerequisites() {
    skip_if_completed "install_prerequisites" "prerequisite installation" && return 0

    step "Installing prerequisites..."

    # FIRST: Ensure we're using zsh
    ensure_zsh
    
    case "${DETECTED_OS}" in
        macos)
            # Install Xcode Command Line Tools
            if ! xcode-select -p &> /dev/null; then
                info "Installing Xcode Command Line Tools..."
                xcode-select --install
                warn "Please complete Xcode Command Line Tools installation and re-run this script"
                return 1
            fi
            
            # Install Homebrew if needed
            if [[ "${PACKAGE_MANAGER}" == "homebrew_install_needed" ]]; then
                install_homebrew
                PACKAGE_MANAGER="brew"
            fi
            
            # Install essential macOS tools
            install_essential_macos_tools
            ;;
        linux)
            # Update package lists and install essential tools
            case "${PACKAGE_MANAGER}" in
                apt)
                    info "Updating package lists..."
                    sudo apt-get update -qq
                    sudo apt-get install -y curl git build-essential wget unzip \
                        zsh bash-completion ca-certificates gnupg lsb-release
                    ;;
                dnf)
                    info "Installing prerequisites..."
                    sudo dnf install -y curl git "@development-tools" wget unzip \
                        zsh bash-completion ca-certificates gnupg
                    ;;
                pacman)
                    info "Installing prerequisites..."
                    sudo pacman -Sy --noconfirm curl git base-devel wget unzip \
                        zsh bash-completion ca-certificates gnupg
                    ;;
            esac
            
            # Install essential Linux tools
            install_essential_linux_tools
            ;;
        windows)
            # Assume WSL2 with basic tools available
            info "Assuming WSL2 environment with basic tools"
            install_essential_wsl_tools
            ;;
    esac

    mark_checkpoint "install_prerequisites"
}

# Install Homebrew (macOS/Linux)
install_homebrew() {
    skip_if_completed "install_homebrew" "Homebrew installation" && return 0

    info "Installing Homebrew..."
    warn "This will download and execute the Homebrew installer"
    warn "Please review: https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    
    # Check if we're in a non-interactive environment
    if [[ ! -t 0 ]]; then
        warn "Running in non-interactive mode (piped from curl)"
        warn "Homebrew installation requires administrator privileges"
        echo
        error "Cannot install Homebrew in non-interactive mode"
        info "Please run the script locally to allow password prompts:"
        info "  curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh > setup.sh"
        info "  bash setup.sh"
        echo
        info "Alternatively, install Homebrew manually first:"
        info "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        info "Then re-run this script."
        return 1
    fi

    local installer="/tmp/dotfiles_setup_homebrew_$$.sh"

    if retry_command 3 5 curl --connect-timeout 10 --max-time 300 -fsSL "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" -o "${installer}"; then
        # Basic verification
        if head -n1 "${installer}" | grep -q '^#!/bin/bash'; then
            # Don't set NONINTERACTIVE - let Homebrew handle interactivity
            /bin/bash "${installer}"
            rm -f "${installer}"

            # Verify installation
            update_path
            if ! command -v brew >/dev/null 2>&1; then
                error "Homebrew was installed but 'brew' command is not accessible"
                return 1
            fi
            success "Homebrew installed and accessible"
        else
            error "Downloaded Homebrew installer appears invalid"
            rm -f "${installer}"
            return 1
        fi
    else
        error "Failed to download Homebrew installer"
        return 1
    fi
    
    # Add to PATH for this session
    case "${DETECTED_OS}" in
        macos)
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            ;;
        linux)
            if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            fi
            ;;
    esac

    mark_checkpoint "install_homebrew"
}

# Install chezmoi
install_chezmoi() {
    skip_if_completed "install_chezmoi" "chezmoi installation" && return 0

    # Update PATH first
    update_path

    if command -v chezmoi >/dev/null 2>&1; then
        info "chezmoi already installed: $(chezmoi --version | head -n1)"
        mark_checkpoint "install_chezmoi"
        return 0
    fi

    step "Installing chezmoi..."

    local install_success=false

    case "${PACKAGE_MANAGER}" in
        brew)
            if retry_command 3 5 brew install chezmoi; then
                install_success=true
            fi
            ;;
        apt|dnf)
            # Use binary install for chezmoi on Linux
            if install_chezmoi_binary; then
                install_success=true
            fi
            ;;
        pacman)
            if retry_command 3 5 sudo pacman -S --noconfirm chezmoi; then
                install_success=true
            fi
            ;;
        winget)
            if retry_command 3 5 winget install twpayne.chezmoi; then
                install_success=true
            fi
            ;;
        scoop)
            if retry_command 3 5 scoop install chezmoi; then
                install_success=true
            fi
            ;;
        *)
            if install_chezmoi_binary; then
                install_success=true
            fi
            ;;
    esac

    if [[ "${install_success}" != "true" ]]; then
        error "Failed to install chezmoi"
        return 1
    fi

    # Refresh PATH and verify installation
    update_path
    if ! command -v chezmoi >/dev/null 2>&1; then
        error "chezmoi was installed but is not accessible in PATH"
        info "Please ensure $HOME/.local/bin is in your PATH"
        return 1
    fi

    success "chezmoi installed: $(chezmoi --version | head -n1)"
    mark_checkpoint "install_chezmoi"
}


# Install essential macOS tools
install_essential_macos_tools() {
    step "Installing essential macOS tools..."
    
    # Install Zsh if not already installed
    if ! command -v zsh >/dev/null 2>&1; then
        info "Installing Zsh..."
        if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
            brew install zsh
        fi
    fi
    
    # Install GNU Stow for dotfile management
    if ! command -v stow >/dev/null 2>&1; then
        info "Installing GNU Stow..."
        if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
            brew install stow
        fi
    fi
    
    # Install essential command-line tools
    local essential_tools=(
        "git"
        "curl"
        "wget"
        "unzip"
        "tree"
        "jq"
        "mas"
    )
    
    for tool in "${essential_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            info "Installing $tool..."
            if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
                brew install "$tool"
            fi
        fi
    done
    
    success "Essential macOS tools installed"
}

# Install essential Linux tools
install_essential_linux_tools() {
    step "Installing essential Linux tools..."
    
    # Install Zsh if not already installed
    if ! command -v zsh >/dev/null 2>&1; then
        info "Installing Zsh..."
        case "${PACKAGE_MANAGER}" in
            apt)
                sudo apt-get install -y zsh
                ;;
            dnf)
                sudo dnf install -y zsh
                ;;
            pacman)
                sudo pacman -S --noconfirm zsh
                ;;
        esac
    fi
    
    # Install Stow for dotfile management
    if ! command -v stow >/dev/null 2>&1; then
        info "Installing GNU Stow..."
        case "${PACKAGE_MANAGER}" in
            apt)
                sudo apt-get install -y stow
                ;;
            dnf)
                sudo dnf install -y stow
                ;;
            pacman)
                sudo pacman -S --noconfirm stow
                ;;
        esac
    fi
    
    # Install essential command-line tools
    case "${PACKAGE_MANAGER}" in
        apt)
            sudo apt-get install -y tree jq htop neofetch
            ;;
        dnf)
            sudo dnf install -y tree jq htop neofetch
            ;;
        pacman)
            sudo pacman -S --noconfirm tree jq htop neofetch
            ;;
    esac
    
    success "Essential Linux tools installed"
}

# Install essential WSL tools
install_essential_wsl_tools() {
    step "Installing essential WSL tools..."
    
    # Detect WSL distribution
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                sudo apt-get update -qq
                sudo apt-get install -y zsh stow tree jq htop neofetch
                ;;
            fedora)
                sudo dnf install -y zsh stow tree jq htop neofetch
                ;;
            arch)
                sudo pacman -Sy --noconfirm zsh stow tree jq htop neofetch
                ;;
        esac
    fi
    
    success "Essential WSL tools installed"
}

# Install modern CLI tools
install_modern_cli_tools() {
    if [[ "${SKIP_MODERN_TOOLS}" == "true" ]]; then
        info "Skipping modern CLI tools installation (--skip-modern-tools specified)"
        return 0
    fi
    
    step "Installing modern CLI tools..."
    
    case "${DETECTED_OS}" in
        macos)
            if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
                local modern_tools=(
                    "ripgrep"      # Better grep
                    "fd"           # Better find
                    "bat"          # Better cat
                    "eza"          # Better ls
                    "zoxide"       # Better cd
                    "fzf"          # Fuzzy finder
                    "delta"        # Better git diff
                    "lazygit"      # Git TUI
                    "gh"           # GitHub CLI
                    "tldr"         # Better man
                    "btop"         # Better top
                    "dust"         # Better du
                    "procs"        # Better ps
                    "httpie"       # Better curl
                    "mdcat"        # Markdown cat
                    "tokei"        # Code statistics
                )
                
                for tool in "${modern_tools[@]}"; do
                    if ! command -v "$tool" >/dev/null 2>&1; then
                        info "Installing $tool..."
                        brew install "$tool"
                    fi
                done
            fi
            ;;
        linux)
            # Install modern tools via package manager where available
            case "${PACKAGE_MANAGER}" in
                apt)
                    # Ubuntu/Debian specific modern tools
                    sudo apt-get install -y ripgrep fd-find bat fzf gh
                    ;;
                dnf)
                    # Fedora specific modern tools
                    sudo dnf install -y ripgrep fd-find bat fzf gh
                    ;;
                pacman)
                    # Arch specific modern tools
                    sudo pacman -S --noconfirm ripgrep fd bat fzf github-cli
                    ;;
            esac
            ;;
    esac
    
    success "Modern CLI tools installed"
}

# Setup shell environment
setup_shell_environment() {
    skip_if_completed "setup_shell_environment" "shell environment setup" && return 0

    step "Setting up shell environment..."
    
    # Set Zsh as default shell
    if command -v zsh >/dev/null 2>&1; then
        local zsh_path
        zsh_path="$(command -v zsh)"
        
        # Add zsh to /etc/shells if not present
        if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
            info "Adding zsh to /etc/shells..."
            
            # Check if we're in non-interactive mode
            if [[ ! -t 0 ]]; then
                warn "Running in non-interactive mode - cannot add zsh to /etc/shells"
                info "Please run manually later: echo '$zsh_path' | sudo tee -a /etc/shells"
            else
                # Interactive mode - can prompt for password
                if echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null 2>&1; then
                    success "Added zsh to /etc/shells"
                else
                    warn "Failed to add zsh to /etc/shells"
                    info "Please run manually: echo '$zsh_path' | sudo tee -a /etc/shells"
                fi
            fi
        else
            debug "zsh already present in /etc/shells"
        fi
        
        # Change default shell to zsh
        if [[ "$SHELL" != "$zsh_path" ]]; then
            info "Setting zsh as default shell..."
            if chsh -s "$zsh_path" 2>/dev/null; then
                success "Default shell set to zsh"
            else
                warn "Could not set zsh as default shell automatically"
                info "Run: chsh -s $zsh_path"
            fi
        else
            debug "zsh is already the default shell"
        fi
    else
        warn "zsh not found - skipping shell environment setup"
    fi

    success "Shell environment configured"
    mark_checkpoint "setup_shell_environment"
}

# Install chezmoi binary directly
install_chezmoi_binary() {
    info "Installing chezmoi binary..."

    local install_dir="$HOME/.local/bin"
    mkdir -p "${install_dir}"

    # Ensure PATH includes install directory BEFORE installation
    export PATH="${install_dir}:${PATH}"

    # Download and install chezmoi with retry logic
    local max_attempts=3
    local attempt=1

    while (( attempt <= max_attempts )); do
        if curl --connect-timeout 10 --max-time 300 -fsSL "https://get.chezmoi.io" | sh -s -- -b "${install_dir}"; then
            success "chezmoi binary installed to ${install_dir}"

            # Verify chezmoi is accessible
            if command -v chezmoi >/dev/null 2>&1; then
                return 0
            else
                error "chezmoi was installed but is not accessible in PATH"
                info "Current PATH: ${PATH}"
                return 1
            fi
        fi

        if (( attempt < max_attempts )); then
            warn "Failed to install chezmoi (attempt ${attempt}/${max_attempts}), retrying..."
            sleep 5
        fi
        ((attempt++))
    done

    error "Failed to install chezmoi binary after ${max_attempts} attempts"
    return 1
}

# Install dotfiles
install_dotfiles() {
    skip_if_completed "install_dotfiles" "dotfiles installation" && return 0

    step "Installing dotfiles configuration..."

    # Update PATH to ensure chezmoi is available
    update_path

    # Determine if we're using local or remote dotfiles
    local use_local=false
    local dotfiles_repo=""

    if [[ -d "$HOME/dotfiles" && -f "$HOME/dotfiles/.chezmoi.yaml.tmpl" ]]; then
        use_local=true
        dotfiles_repo="$HOME/dotfiles"
        info "Found local dotfiles at $dotfiles_repo"
    else
        dotfiles_repo="${REPO_URL%.git}"  # Remove .git suffix
        info "Using remote repository: ${REPO_URL}"
    fi

    # Check if chezmoi is already initialized
    local chezmoi_source_dir="${HOME}/.local/share/chezmoi"
    local already_initialized=false

    if [[ -d "${chezmoi_source_dir}/.git" ]]; then
        info "Chezmoi source directory already exists"
        already_initialized=true
    fi

    # Initialize chezmoi
    if [[ "${already_initialized}" == "false" ]]; then
        info "Initializing chezmoi..."

        if [[ "$use_local" == "true" ]]; then
            # For local dotfiles, use source directory
            if retry_command 2 3 chezmoi init --source="$HOME/dotfiles"; then
                success "Chezmoi initialized with local dotfiles"
            else
                error "Failed to initialize chezmoi with local dotfiles"
                return 1
            fi
        else
            # For remote repository, use chezmoi's standard approach
            if retry_command 3 5 chezmoi init "${REPO_URL}"; then
                success "Chezmoi initialized with remote repository"
            else
                error "Failed to initialize chezmoi with remote repository"
                return 1
            fi
        fi
    else
        info "Updating existing chezmoi source directory..."
        if retry_command 2 3 chezmoi update --no-tty; then
            success "Chezmoi source updated"
        else
            warn "Failed to update chezmoi source, continuing with existing version"
        fi
    fi

    # Apply dotfiles
    info "Applying dotfiles configuration..."
    if retry_command 2 3 chezmoi apply --force; then
        success "Dotfiles applied successfully"

        # Verify key directories were created
        if [[ -d "$HOME/.config" ]]; then
            success ".config directory populated"

            # Check specific important directories
            local important_dirs=("zsh" "git" "mise")
            local missing_count=0

            for dir in "${important_dirs[@]}"; do
                if [[ -d "$HOME/.config/$dir" ]]; then
                    debug "✓ .config/$dir exists"
                else
                    warn "✗ .config/$dir missing"
                    ((missing_count++))
                fi
            done

            if [[ $missing_count -eq 0 ]]; then
                success "All expected configuration directories created"
            else
                warn "$missing_count configuration directories are missing"
                info "This may be normal if you haven't installed those tools yet"
            fi
        else
            warn ".config directory not created yet - this may be normal"
        fi

        mark_checkpoint "install_dotfiles"
    else
        error "Failed to apply dotfiles"
        return 1
    fi
}

# Install packages
install_packages() {
    if [[ "${SKIP_PACKAGES}" == "true" ]]; then
        info "Skipping package installation (--skip-packages specified)"
        return 0
    fi

    skip_if_completed "install_packages" "package installation" && return 0

    step "Installing packages..."

    # Update PATH before running package scripts
    update_path

    # Install modern CLI tools first (if not skipped)
    if [[ "${SKIP_MODERN_TOOLS}" != "true" ]]; then
        install_modern_cli_tools
    fi

    # The packages will be installed via chezmoi run scripts
    local chezmoi_source_dir
    if ! chezmoi_source_dir="$(chezmoi source-path 2>/dev/null)"; then
        warn "Could not determine chezmoi source directory"
        return 1
    fi

    if [[ -d "${chezmoi_source_dir}" ]]; then
        info "Package installation will be handled by chezmoi scripts"
        info "Running chezmoi to execute installation scripts..."

        # Update PATH again before chezmoi runs scripts
        update_path

        # Apply with retry logic
        if retry_command 2 5 chezmoi apply --force; then
            success "Package installation scripts executed"
            mark_checkpoint "install_packages"

            # Update PATH one more time after packages are installed
            update_path
        else
            warn "Some package installations may have failed"
            info "You can re-run this script to retry, or run 'chezmoi apply' manually"
            return 1
        fi
    else
        warn "Chezmoi source directory not found, skipping package installation"
        return 1
    fi
}

# Post-install setup
post_install() {
    step "Completing setup..."
    
    # Setup shell environment
    setup_shell_environment
    
    # Source configuration for immediate use
    if [[ -f "$HOME/.config/zsh/.zshrc" ]]; then
        info "zsh configuration ready at ~/.config/zsh/.zshrc"
    fi
    
    # Create common directories
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.config"
    
    success "Setup completed successfully!"
}

# Show completion message
show_completion() {
    echo
    echo "🎉 Dotfiles installation complete!"
    echo
    info "What was installed:"
    case "${INSTALL_MODE}" in
        minimal)
            echo "  • Essential tools and configurations"
            echo "  • Shell environment (zsh with completions)"
            echo "  • Basic command-line utilities"
            echo "  • Modern CLI tools (ripgrep, fd, bat, etc.)"
            ;;
        full)
            echo "  • Complete development environment"
            echo "  • Shell environment (zsh with plugins)"
            echo "  • Development tools and languages"
            echo "  • Modern CLI tools (ripgrep, fd, bat, eza, etc.)"
            echo "  • System package management (Homebrew/apt/dnf)"
            echo "  • Command-line utilities and enhancements"
            ;;
    esac
    echo
    info "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Check installation: chezmoi doctor"
    echo "  3. Update dotfiles anytime: chezmoi update"
    echo
    info "For help:"
    echo "  • Documentation: https://github.com/adamNewell/dotfiles"
    echo "  • Issues: https://github.com/adamNewell/dotfiles/issues"
    echo
    if [[ "${INSTALL_MODE}" == "minimal" ]]; then
        info "To install development packages later:"
        echo "  • Run: chezmoi apply --force"
        echo "  • Or reinstall with: curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash"
    fi
}

# Main installation function
main() {
    # If we're running from a file in bash, re-execute in zsh
    if [[ -n "${BASH_VERSION:-}" ]] && [[ -z "${ZSH_VERSION:-}" ]] && [[ -f "$0" ]]; then
        # Ensure zsh is installed first
        if ! command -v zsh >/dev/null 2>&1; then
            info "Installing zsh first..."
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update -qq && sudo apt-get install -y zsh
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y zsh
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm zsh
            elif command -v brew >/dev/null 2>&1; then
                brew install zsh
            fi
        fi
        info "Re-executing in zsh..."
        exec zsh "$0" "$@"
    fi
    
    # Show banner
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                          Dotfiles Setup Script                               ║
║                                                                              ║
║           Universal installer for development environment                    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    
    info "Starting dotfiles installation (version ${SCRIPT_VERSION})"
    echo
    
    # Parse arguments
    parse_args "$@"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        error "Do not run this script as root"
        return 1
    fi
    
    # Detection phase (needed for bash version handling)
    detect_platform
    info "Platform detection completed, proceeding to package manager detection..."

    detect_package_manager

    info "Package manager detection completed, proceeding with installation..."
    
    echo
    info "Installation mode: ${INSTALL_MODE}"
    info "Package manager: ${PACKAGE_MANAGER}"
    if [[ "${SKIP_PACKAGES}" == "true" ]]; then
        info "Package installation: SKIPPED"
    fi
    echo
    
    # Installation phases
    info "Starting installation phases..."
    install_prerequisites
    install_chezmoi
    install_dotfiles
    install_packages
    post_install
    
    # Show completion message
    show_completion
}

# Run main function with all arguments
main "$@"