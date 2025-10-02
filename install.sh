#!/bin/sh
# Minimal bootstrap script for chezmoi-based dotfiles
# Usage: sh -c "$(curl -fsLS https://raw.githubusercontent.com/adamNewell/dotfiles/main/install.sh)"

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { printf "${BLUE}ℹ️  %s${NC}\n" "$1"; }
success() { printf "${GREEN}✅ %s${NC}\n" "$1"; }
warn() { printf "${YELLOW}⚠️  %s${NC}\n" "$1"; }
error() { printf "${RED}❌ %s${NC}\n" "$1" >&2; }

# Configuration
REPO_URL="https://github.com/adamNewell/dotfiles.git"

main() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           Dotfiles Installation via Chezmoi                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo

    # Check if running as root
    if [ "$(id -u)" -eq 0 ]; then
        error "Do not run this script as root"
        exit 1
    fi

    # Install chezmoi if not already installed
    if ! command -v chezmoi >/dev/null 2>&1; then
        info "Installing chezmoi..."

        # Ensure .local/bin exists
        mkdir -p "${HOME}/.local/bin"

        # Download and install chezmoi
        if sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"; then
            success "Chezmoi installed successfully"

            # Add to PATH for this session
            export PATH="${HOME}/.local/bin:${PATH}"
        else
            error "Failed to install chezmoi"
            exit 1
        fi
    else
        info "Chezmoi already installed: $(chezmoi --version)"
    fi

    # Initialize and apply dotfiles
    info "Initializing dotfiles from ${REPO_URL}..."

    if [ -d "${HOME}/.local/share/chezmoi/.git" ]; then
        info "Dotfiles already initialized, updating..."
        if chezmoi update --no-tty; then
            success "Dotfiles updated successfully"
        else
            error "Failed to update dotfiles"
            exit 1
        fi
    else
        info "Cloning dotfiles repository..."
        if chezmoi init --apply "${REPO_URL}"; then
            success "Dotfiles initialized and applied successfully"
        else
            error "Failed to initialize dotfiles"
            exit 1
        fi
    fi

    echo
    success "Installation complete!"
    echo
    info "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Check installation: chezmoi doctor"
    echo "  3. Update dotfiles anytime: chezmoi update"
    echo
    info "Configuration:"
    echo "  • Dotfiles location: ${HOME}/.local/share/chezmoi"
    echo "  • Edit config: chezmoi edit --apply ~/.zshrc"
    echo "  • View changes: chezmoi diff"
    echo
}

main "$@"
