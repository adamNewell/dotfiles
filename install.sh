#!/bin/bash
# One-line installer for new machines
# Usage: curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}" >&2; }

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This installer is designed for macOS"
    exit 1
fi

info "Starting dotfiles installation..."

# Install Xcode Command Line Tools if needed
if ! xcode-select -p &> /dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    warn "Please complete Xcode Command Line Tools installation and re-run this script"
    exit 1
fi

# Install chezmoi if not present
if ! command -v chezmoi >/dev/null 2>&1; then
    info "Installing chezmoi..."
    if command -v brew >/dev/null 2>&1; then
        brew install chezmoi
    else
        # Install Homebrew first
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for this session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        brew install chezmoi
    fi
fi

# Initialize chezmoi with the dotfiles repository
info "Initializing chezmoi with dotfiles repository..."
chezmoi init --apply https://github.com/adamNewell/.dotfiles.git

success "Dotfiles installation complete!"
info "Please restart your terminal or run: source ~/.config/zsh/.zshrc"
info "Note: Some changes may require a full logout/login to take effect"