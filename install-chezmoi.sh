#!/bin/bash
# Quick script to install chezmoi binary

set -e

echo "Installing chezmoi..."

# Install chezmoi to ~/.local/bin
export BINDIR="$HOME/.local/bin"
mkdir -p "$BINDIR"

# Download and install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BINDIR"

# Make sure it's in PATH for current session
export PATH="$BINDIR:$PATH"

echo "✅ chezmoi installed to $BINDIR"
echo "📌 Run: export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "📌 Then: chezmoi init --apply ."