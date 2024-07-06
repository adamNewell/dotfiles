#!/bin/bash

# Check if Xcode Command Line Tools are already installed
if xcode-select -p &> /dev/null; then
    echo "Xcode Command Line Tools are already installed."
else
    echo "Xcode Command Line Tools not found. Installing..."
    
    # Trigger the installation
    xcode-select --install &> /dev/null
    
    # Wait for the installation to complete
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    
    echo "Xcode Command Line Tools have been installed."
fi

# Accept the license agreement
sudo xcodebuild -license accept

echo "Installation and license agreement completed."
