#!/bin/bash
# Universal dotfiles installer and environment setup
# Supports macOS, Linux, and Windows (WSL)
# Usage: curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash

set -e
set -o pipefail

# Configuration
readonly REPO_URL="https://github.com/adamNewell/.dotfiles.git"
readonly SCRIPT_VERSION="2.0.0"
readonly MIN_BASH_VERSION=4

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Logging functions
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}" >&2; }
debug() { [[ "${DEBUG:-}" == "1" ]] && echo -e "${PURPLE}🐛 $1${NC}" >&2; }
step() { echo -e "${CYAN}▶️  $1${NC}"; }

# Global variables
DETECTED_OS=""
DETECTED_ARCH=""
PACKAGE_MANAGER=""
INSTALL_MODE="full"
SKIP_PACKAGES=""

# Cleanup function
cleanup() {
    local exit_code=$?
    debug "Cleaning up temporary files..."
    rm -f /tmp/dotfiles_setup_*
    if [[ ${exit_code} -ne 0 ]]; then
        error "Installation failed with exit code ${exit_code}"
        echo
        info "For help, visit: https://github.com/adamNewell/.dotfiles/issues"
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
    curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash
    
    # Or with options:
    curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash -s -- [OPTIONS]

OPTIONS:
    --minimal           Install only essential tools (no development packages)
    --skip-packages     Skip package installation entirely
    --debug            Enable debug output
    --help             Show this help message

EXAMPLES:
    # Full installation
    curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash
    
    # Minimal installation
    curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash -s -- --minimal
    
    # Skip packages (config only)
    curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash -s -- --skip-packages

SUPPORTED PLATFORMS:
    - macOS (Intel and Apple Silicon)
    - Linux (Ubuntu, Debian, Fedora, Arch Linux)
    - Windows (WSL2)

For more information, visit: https://github.com/adamNewell/.dotfiles
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
            --debug)
                export DEBUG=1
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                warn "Unknown option: $1"
                show_usage
                exit 1
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
            exit 1
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
            if command -v brew >/dev/null 2>&1; then
                PACKAGE_MANAGER="brew"
            else
                PACKAGE_MANAGER="homebrew_install_needed"
            fi
            ;;
        linux)
            if command -v apt-get >/dev/null 2>&1; then
                PACKAGE_MANAGER="apt"
            elif command -v dnf >/dev/null 2>&1; then
                PACKAGE_MANAGER="dnf"
            elif command -v pacman >/dev/null 2>&1; then
                PACKAGE_MANAGER="pacman"
            elif command -v zypper >/dev/null 2>&1; then
                PACKAGE_MANAGER="zypper"
            else
                error "No supported package manager found"
                exit 1
            fi
            ;;
        windows)
            if command -v winget >/dev/null 2>&1; then
                PACKAGE_MANAGER="winget"
            elif command -v scoop >/dev/null 2>&1; then
                PACKAGE_MANAGER="scoop"
            else
                warn "No Windows package manager found, will install via external downloads"
                PACKAGE_MANAGER="none"
            fi
            ;;
    esac
    
    debug "Package manager: ${PACKAGE_MANAGER}"
}

# Install prerequisites
install_prerequisites() {
    step "Installing prerequisites..."
    
    case "${DETECTED_OS}" in
        macos)
            # Install Xcode Command Line Tools
            if ! xcode-select -p &> /dev/null; then
                info "Installing Xcode Command Line Tools..."
                xcode-select --install
                warn "Please complete Xcode Command Line Tools installation and re-run this script"
                exit 1
            fi
            
            # Install Homebrew if needed
            if [[ "${PACKAGE_MANAGER}" == "homebrew_install_needed" ]]; then
                install_homebrew
                PACKAGE_MANAGER="brew"
            fi
            ;;
        linux)
            # Update package lists
            case "${PACKAGE_MANAGER}" in
                apt)
                    info "Updating package lists..."
                    sudo apt-get update -qq
                    sudo apt-get install -y curl git build-essential
                    ;;
                dnf)
                    info "Installing prerequisites..."
                    sudo dnf install -y curl git "@development-tools"
                    ;;
                pacman)
                    info "Installing prerequisites..."
                    sudo pacman -Sy --noconfirm curl git base-devel
                    ;;
            esac
            ;;
        windows)
            # Assume WSL2 with basic tools available
            info "Assuming WSL2 environment with basic tools"
            ;;
    esac
}

# Install Homebrew (macOS/Linux)
install_homebrew() {
    info "Installing Homebrew..."
    warn "This will download and execute the Homebrew installer"
    warn "Please review: https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    
    local installer="/tmp/dotfiles_setup_homebrew_$$.sh"
    
    if curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" -o "${installer}"; then
        # Basic verification
        if head -n1 "${installer}" | grep -q '^#!/bin/bash'; then
            /bin/bash "${installer}"
            rm -f "${installer}"
        else
            error "Downloaded Homebrew installer appears invalid"
            exit 1
        fi
    else
        error "Failed to download Homebrew installer"
        exit 1
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
}

# Install chezmoi
install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        info "chezmoi already installed: $(chezmoi --version | head -n1)"
        return 0
    fi
    
    step "Installing chezmoi..."
    
    case "${PACKAGE_MANAGER}" in
        brew)
            brew install chezmoi
            ;;
        apt)
            # Use binary install for chezmoi on Ubuntu/Debian
            install_chezmoi_binary
            ;;
        dnf)
            # Use binary install for chezmoi on Fedora
            install_chezmoi_binary
            ;;
        pacman)
            sudo pacman -S --noconfirm chezmoi
            ;;
        winget)
            winget install twpayne.chezmoi
            ;;
        scoop)
            scoop install chezmoi
            ;;
        *)
            install_chezmoi_binary
            ;;
    esac
    
    if ! command -v chezmoi >/dev/null 2>&1; then
        error "Failed to install chezmoi"
        exit 1
    fi
    
    success "chezmoi installed: $(chezmoi --version | head -n1)"
}

# Install chezmoi binary directly
install_chezmoi_binary() {
    info "Installing chezmoi binary..."
    
    local install_dir="$HOME/.local/bin"
    mkdir -p "${install_dir}"
    
    # Download and install chezmoi
    if curl -fsSL "https://get.chezmoi.io" | sh -s -- -b "${install_dir}"; then
        export PATH="${install_dir}:${PATH}"
        success "chezmoi binary installed"
    else
        error "Failed to install chezmoi binary"
        exit 1
    fi
}

# Install dotfiles
install_dotfiles() {
    step "Installing dotfiles configuration..."
    
    # Initialize chezmoi with the repository
    info "Initializing chezmoi with dotfiles repository..."
    if chezmoi init --apply "${REPO_URL}"; then
        success "Dotfiles applied successfully"
    else
        error "Failed to apply dotfiles"
        exit 1
    fi
}

# Install packages
install_packages() {
    if [[ "${SKIP_PACKAGES}" == "true" ]]; then
        info "Skipping package installation (--skip-packages specified)"
        return 0
    fi
    
    step "Installing packages..."
    
    # The packages will be installed via chezmoi run scripts
    # Just ensure the scripts are executable and run them
    
    local chezmoi_source_dir
    chezmoi_source_dir="$(chezmoi source-path)"
    
    if [[ -d "${chezmoi_source_dir}" ]]; then
        info "Package installation will be handled by chezmoi scripts"
        info "Running chezmoi to execute installation scripts..."
        
        # Force re-run of installation scripts
        chezmoi apply --force
        
        success "Package installation initiated"
    else
        warn "Chezmoi source directory not found, skipping package installation"
    fi
}

# Post-install setup
post_install() {
    step "Completing setup..."
    
    # Set default shell to zsh if not already
    if [[ "${SHELL}" != *"zsh"* ]] && command -v zsh >/dev/null 2>&1; then
        info "Setting zsh as default shell..."
        local zsh_path
        zsh_path="$(command -v zsh)"
        
        if ! grep -q "${zsh_path}" /etc/shells 2>/dev/null; then
            echo "${zsh_path}" | sudo tee -a /etc/shells >/dev/null
        fi
        
        if chsh -s "${zsh_path}" 2>/dev/null; then
            success "Default shell set to zsh"
        else
            warn "Could not set zsh as default shell automatically"
            info "Run: chsh -s $(command -v zsh)"
        fi
    fi
    
    # Source configuration for immediate use
    if [[ -f "$HOME/.config/zsh/.zshrc" ]]; then
        info "zsh configuration ready at ~/.config/zsh/.zshrc"
    fi
    
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
            echo "  • Shell environment (zsh)"
            echo "  • Basic command-line utilities"
            ;;
        full)
            echo "  • Complete development environment"
            echo "  • Shell environment (zsh with plugins)"
            echo "  • Development tools and languages"
            echo "  • Command-line utilities"
            ;;
    esac
    echo
    info "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Check installation: chezmoi doctor"
    echo "  3. Update dotfiles anytime: chezmoi update"
    echo
    info "For help:"
    echo "  • Documentation: https://github.com/adamNewell/.dotfiles"
    echo "  • Issues: https://github.com/adamNewell/.dotfiles/issues"
    echo
    if [[ "${INSTALL_MODE}" == "minimal" ]]; then
        info "To install development packages later:"
        echo "  • Run: chezmoi apply --force"
        echo "  • Or reinstall with: curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash"
    fi
}

# Main installation function
main() {
    # Show banner
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                          Dotfiles Setup Script                              ║
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
        exit 1
    fi
    
    # Verify bash version for associative arrays (if needed)
    if [[ ${BASH_VERSION%%.*} -lt ${MIN_BASH_VERSION} ]]; then
        warn "Old bash version detected (${BASH_VERSION})"
        warn "Some features may not work correctly"
    fi
    
    # Detection phase
    detect_platform
    detect_package_manager
    
    echo
    info "Installation mode: ${INSTALL_MODE}"
    info "Package manager: ${PACKAGE_MANAGER}"
    if [[ "${SKIP_PACKAGES}" == "true" ]]; then
        info "Package installation: SKIPPED"
    fi
    echo
    
    # Installation phases
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