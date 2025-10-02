#!/usr/bin/env bash
set -euo pipefail

set -euo pipefail
echo "Installing pre-commit hooks using an isolated venv..."

# Location for the helper venv inside the repo (doesn't pollute user site)
VENV_DIR=".cache/pre-commit-venv"

python3 -m venv "$VENV_DIR"
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

pip install --upgrade pip
pip install pre-commit

# Prevent pip inside hook virtualenvs from reading user pip configuration
export PYTHONNOUSERSITE=1
export PIP_CONFIG_FILE=/dev/null

pre-commit install --install-hooks
echo "pre-commit hooks installed from venv at $VENV_DIR."
echo "To run hooks locally: $VENV_DIR/bin/pre-commit run --all-files"
