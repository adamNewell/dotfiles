#!/bin/bash

# Source the shared output functions
source "$(dirname "$0")/../install/output_functions.sh"

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

eval "$(/opt/homebrew/bin/brew shellenv)"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."

    # Install Homebrew
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Check if installation was successful
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew has been successfully installed."
    else
        echo "Failed to install Homebrew. Please check your internet connection and try again."
        exit 1
    fi
fi

# Check if Brewfile exists in the same directory as the script
if [ ! -f "$SCRIPT_DIR/Brewfile" ]; then
    fail "Brewfile not found in the script directory: $SCRIPT_DIR"
fi

info "Installing Homebrew packages from Brewfile..."

# Update Homebrew
brew update

# Install from Brewfile
if brew bundle --file="$SCRIPT_DIR/Brewfile"; then
    success "All packages from Brewfile have been successfully installed."
else
    fail "Some packages failed to install. Please check the output above for details."
fi

# Cleanup
info "Cleaning up..."
brew cleanup

success "Homebrew package installation complete!"
