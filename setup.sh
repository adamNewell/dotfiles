#!/bin/bash
# Universal dotfiles installer and environment setup
# Supports macOS, Linux, and Windows (WSL)
# 
# Features:
# - Automatic platform detection and package manager selection
# - Modern bash installation (if needed for compatibility)
# - Homebrew installation and management
# - Essential tool installation (git, curl, zsh, stow, etc.)
# - Modern CLI tools (ripgrep, fd, bat, eza, fzf, etc.)
# - Shell environment setup (zsh as default)
# - Chezmoi dotfile management
# - Comprehensive error handling and logging
#
# Usage: curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash

set -e
set -o pipefail

# Configuration
readonly REPO_URL="https://github.com/adamNewell/dotfiles.git"
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
info() { echo -e "${BLUE}ℹ️  $1${NC}" || true; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}" >&2; }
debug() { [[ "${DEBUG:-}" == "1" ]] && echo -e "${PURPLE}🐛 $1${NC}" >&2 || true; }
step() { echo -e "${CYAN}▶️  $1${NC}"; }

# Global variables
DETECTED_OS=""
DETECTED_ARCH=""
PACKAGE_MANAGER=""
INSTALL_MODE="full"
SKIP_PACKAGES=""
SKIP_MODERN_TOOLS=""

# Cleanup function
cleanup() {
    local exit_code=$?
    debug "Cleaning up temporary files..."
    rm -f /tmp/dotfiles_setup_*
    if [[ ${exit_code} -ne 0 ]]; then
        error "Installation failed with exit code ${exit_code}"
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
                exit 1
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
}

# Install Homebrew (macOS/Linux)
install_homebrew() {
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
        exit 1
    fi
    
    local installer="/tmp/dotfiles_setup_homebrew_$$.sh"
    
    if curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" -o "${installer}"; then
        # Basic verification
        if head -n1 "${installer}" | grep -q '^#!/bin/bash'; then
            # Don't set NONINTERACTIVE - let Homebrew handle interactivity
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

# Install modern bash if needed
install_modern_bash_if_needed() {
    local current_bash_version
    local required_version=${MIN_BASH_VERSION}
    
    # Check current bash version
    if command -v bash >/dev/null 2>&1; then
        current_bash_version=$(bash --version | head -n1 | grep -o '[0-9]\+\.[0-9]\+' | head -n1)
        current_bash_major=${current_bash_version%%.*}
        
        if [[ ${current_bash_major} -ge ${required_version} ]]; then
            debug "Current bash version ${current_bash_version} is sufficient"
            return 0
        fi
    else
        warn "No bash found in PATH"
    fi
    
    info "Installing modern bash (current: ${current_bash_version:-none}, required: ${required_version}.x)..."
    
    case "${DETECTED_OS}" in
        macos)
            if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
                # Install modern bash via Homebrew
                brew install bash
                
                # Add new bash to /etc/shells
                local new_bash_path="/opt/homebrew/bin/bash"
                if [[ ! -f "$new_bash_path" ]]; then
                    new_bash_path="/usr/local/bin/bash"
                fi
                
                if [[ -f "$new_bash_path" ]] && ! grep -q "$new_bash_path" /etc/shells 2>/dev/null; then
                    info "Adding new bash to /etc/shells..."
                    echo "$new_bash_path" | sudo tee -a /etc/shells >/dev/null
                fi
                
                success "Modern bash installed: $(${new_bash_path} --version | head -n1)"
            fi
            ;;
        linux)
            case "${PACKAGE_MANAGER}" in
                apt)
                    # Ubuntu/Debian usually have modern bash, but ensure latest
                    sudo apt-get install -y bash
                    ;;
                dnf)
                    # Fedora usually has modern bash
                    sudo dnf install -y bash
                    ;;
                pacman)
                    # Arch usually has modern bash
                    sudo pacman -S --noconfirm bash
                    ;;
            esac
            ;;
        windows)
            # WSL distributions should have modern bash
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                case "$ID" in
                    ubuntu|debian)
                        sudo apt-get install -y bash
                        ;;
                    fedora)
                        sudo dnf install -y bash
                        ;;
                    arch)
                        sudo pacman -S --noconfirm bash
                        ;;
                esac
            fi
            ;;
    esac
    
    # Verify installation
    if command -v bash >/dev/null 2>&1; then
        local new_version
        new_version=$(bash --version 2>/dev/null | head -n1 | grep -o '[0-9]\+\.[0-9]\+' | head -n1)
        local new_major=${new_version%%.*}
        
        if [[ -n "$new_major" ]] && [[ ${new_major} -ge ${required_version} ]]; then
            success "Modern bash ${new_version} is now available"
            return 0
        else
            warn "Bash version ${new_version:-unknown} may still be insufficient for some features"
            warn "Continuing with available bash installation"
            return 1
        fi
    else
        warn "Failed to install modern bash, continuing with system bash"
        warn "Some advanced features may not work properly"
        return 1
    fi
}

# Install essential macOS tools
install_essential_macos_tools() {
    step "Installing essential macOS tools..."
    
    # Skip bash installation since it's already handled in the main function
    # install_modern_bash_if_needed
    
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
    
    # Skip bash installation since it's already handled in the main function
    # install_modern_bash_if_needed
    
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
    
    # Skip bash installation since it's already handled in the main function
    # install_modern_bash_if_needed
    
    # Detect WSL distribution
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                sudo apt-get update -qq
                sudo apt-get install -y bash zsh stow tree jq htop neofetch
                ;;
            fedora)
                sudo dnf install -y bash zsh stow tree jq htop neofetch
                ;;
            arch)
                sudo pacman -Sy --noconfirm bash zsh stow tree jq htop neofetch
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
    
    # Initialize chezmoi
    info "Initializing chezmoi..."
    
    if [[ "$use_local" == "true" ]]; then
        # For local dotfiles, ensure clean state first
        info "Preparing for local chezmoi initialization..."
        rm -rf "$HOME/.local/share/chezmoi"
        rm -rf "$HOME/.config/chezmoi"
        
        # Initialize chezmoi with the local repository as source
        if chezmoi init --apply --source="$HOME/dotfiles"; then
            success "Chezmoi initialized with local dotfiles"
        else
            error "Failed to initialize chezmoi with local dotfiles"
            exit 1
        fi
    else
        # For remote repository, use chezmoi's standard approach
        info "Using remote repository: ${REPO_URL}"
        
        # Ensure clean state before initialization
        info "Preparing for chezmoi initialization..."
        rm -rf "$HOME/.local/share/chezmoi"
        rm -rf "$HOME/.config/chezmoi"
        
        # Use chezmoi's standard repository handling
        info "Initializing chezmoi with repository..."
        if chezmoi init --apply "${REPO_URL}"; then
            success "Chezmoi initialized and applied with remote repository"
        else
            error "Failed to initialize chezmoi with remote repository"
            exit 1
        fi
    fi
    
    # Ensure chezmoi applies all files
    info "Ensuring all dotfiles are applied..."
    if chezmoi apply --force; then
        success "Dotfiles applied successfully"
        
        # Verify key directories were created
        if [[ -d "$HOME/.config" ]]; then
            success ".config directory populated"
            
            # Check specific important directories
            local important_dirs=("zsh" "fzf" "git" "nvim" "kitty" "sheldon" "tmux")
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
                info "Run 'chezmoi apply' manually to fix any missing files"
            fi
        else
            error ".config directory not created - chezmoi configuration failed"
            exit 1
        fi
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
    
    # Install modern CLI tools first
    install_modern_cli_tools
    
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
        exit 1
    fi
    
    # Detection phase (needed for bash version handling)
    detect_platform
    info "Platform detection completed, proceeding to package manager detection..."
    
    # Temporarily disable set -e for package manager detection
    set +e
    detect_package_manager
    set -e
    
    info "Package manager detection completed, proceeding to bash version check..."
    
    # Verify bash version for associative arrays (if needed)
    local current_bash_major
    current_bash_major=${BASH_VERSION%%.*}
    
    # Handle cases where BASH_VERSION might be empty or malformed
    if [[ -z "$current_bash_major" ]] || ! [[ "$current_bash_major" =~ ^[0-9]+$ ]]; then
        warn "Could not determine bash version, assuming compatibility issues"
        current_bash_major=0
    fi
    
    debug "Current bash major version: $current_bash_major, required: $MIN_BASH_VERSION"
    
    if [[ ${current_bash_major} -lt ${MIN_BASH_VERSION} ]]; then
        warn "Old bash version detected (${BASH_VERSION})"
        warn "Installing modern bash to ensure compatibility..."
        
        # Pre-install modern bash if needed
        case "${DETECTED_OS}" in
            macos)
                # On macOS, we need Homebrew first
                if [[ "${PACKAGE_MANAGER}" == "homebrew_install_needed" ]]; then
                    install_homebrew
                    PACKAGE_MANAGER="brew"
                fi
                ;;
        esac
        
        # Install modern bash (with error handling)
        if ! install_modern_bash_if_needed; then
            warn "Modern bash installation encountered issues, continuing with current bash"
        fi
        
        # Find the best bash available
        local new_bash_path
        case "${DETECTED_OS}" in
            macos)
                # Try Homebrew locations
                if [[ -f "/opt/homebrew/bin/bash" ]]; then
                    new_bash_path="/opt/homebrew/bin/bash"
                elif [[ -f "/usr/local/bin/bash" ]]; then
                    new_bash_path="/usr/local/bin/bash"
                else
                    new_bash_path="$(command -v bash)"
                fi
                ;;
            *)
                new_bash_path="$(command -v bash)"
                ;;
        esac
        
        if [[ -f "$new_bash_path" ]]; then
            local new_version
            new_version=$("$new_bash_path" --version 2>/dev/null | head -n1 | grep -o '[0-9]\+\.[0-9]\+' | head -n1)
            local new_major=${new_version%%.*}
            
            if [[ -n "$new_major" ]] && [[ ${new_major} -ge ${MIN_BASH_VERSION} ]]; then
                info "Modern bash ${new_version} is now available at: $new_bash_path"
                # Check if script is being run from a file or piped
                if [[ -f "$0" && -x "$new_bash_path" ]]; then
                    info "Rerunning script with modern bash for optimal compatibility..."
                    exec "$new_bash_path" "$0" "$@"
                else
                    info "Script is being run via pipe, continuing with current bash"
                    info "Modern bash ${new_version} is available for future use"
                fi
            else
                warn "Modern bash installation may have failed, continuing with current bash"
                warn "Some advanced features may not work properly"
            fi
        else
            warn "Could not find suitable bash installation, continuing with current bash"
            warn "Some advanced features may not work properly"
        fi
    else
        debug "Bash version ${BASH_VERSION} is sufficient"
    fi
    
    info "Bash version check completed, continuing with installation..."
    
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