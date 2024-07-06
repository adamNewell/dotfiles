#!/bin/bash

# Check if Homebrew is already installed
if command -v brew >/dev/null 2>&1; then
    echo "Homebrew is already installed."
    echo "Installing Homebrew packages..."
else
    echo "Homebrew is not installed. Installing now..."
    
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Check if installation was successful
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew has been successfully installed."
            
        echo "Homebrew has been added to your PATH for this session."
        echo "Note: You may need to add Homebrew to your PATH permanently in your shell configuration file."
    else
        echo "Failed to install Homebrew. Please check your internet connection and try again."
        return 1
    fi
fi

