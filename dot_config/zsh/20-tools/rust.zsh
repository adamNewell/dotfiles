# =============================================================================
#                               Rust/Cargo Configuration
# =============================================================================

# Cargo/Rust environment
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Initialize cargo if installed
if [[ -f "$CARGO_HOME/env" ]]; then
    source "$CARGO_HOME/env"
fi
