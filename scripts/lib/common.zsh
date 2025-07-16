#!/usr/bin/env zsh

# Terminal colors for status messages
typeset -gr BOLD=$'\033[1m'
typeset -gr RED=$'\033[0;31m'
typeset -gr GREEN=$'\033[0;32m'
typeset -gr BLUE=$'\033[0;34m'
typeset -gr YELLOW=$'\033[0;33m'
typeset -gr RESET=$'\033[0m'

# Debug level (default: 0 - no debug output)
typeset -g DEBUG_LEVEL=${DEBUG_LEVEL:-0}

# Logging functions
log() { print -P "${BLUE}==> ${RESET}$*" }
info() { print -P "  ${YELLOW}➜${RESET}  $*" }
success() { print -P "  ${GREEN}✔${RESET}  $*" }
error() { print -P "  ${RED}✖${RESET}  $*" >&2 }
die() { error "$1"; exit 1 }
debug() {
    local level=$1
    shift
    if (( DEBUG_LEVEL >= level )); then
        print -P "  ${BLUE}debug[$level]${RESET}  $*"
    fi
}

cleanup() {
    emulate -L zsh
    setopt local_options
    
    local exit_code=$?
    debug 2 "Cleanup: Killing background jobs..."
    kill ${${(v)jobstates##*:*:}%=*} 2>/dev/null
    
    # Only remove temp files if we created them
    if [[ -n $SCRIPT_TMPDIR && -d $SCRIPT_TMPDIR ]]; then
        debug 2 "Cleanup: Removing temporary directory: $SCRIPT_TMPDIR"
        rm -rf $SCRIPT_TMPDIR
    fi
    
    (( exit_code )) && error "Installation failed! Please check the error messages above."
    debug 1 "Cleanup completed with exit code: $exit_code"
    exit $exit_code
}

setup_env() {
    debug 2 "Setting up environment..."
    # Create our own temporary directory
    export SCRIPT_TMPDIR=$(mktemp -d)
    debug 2 "Created temporary directory: $SCRIPT_TMPDIR"
    
    export DOTFILES=${DOTFILES:-$HOME/.dotfiles}
    export STOW_DIR=${STOW_DIR:-$DOTFILES}
    debug 2 "Environment variables set: DOTFILES=$DOTFILES, STOW_DIR=$STOW_DIR"
}

check_system() {
    log "Checking system compatibility"
    debug 2 "System information:"
    debug 2 "  OS: $(uname)"
    debug 2 "  Version: $(sw_vers -productVersion)"
    debug 2 "  Architecture: $(uname -m)"

    [[ $(uname) != "Darwin" ]] && die "This script is only for macOS"
    [[ $(sw_vers -productVersion | cut -d. -f1) -lt 11 ]] && die "This script requires macOS 11.0 or later"
    [[ $(uname -m) != "arm64" ]] && die "This script is only for Apple Silicon Macs"

    success "System compatibility check passed"
}

store_homebrew_packages() {
    emulate -L zsh
    setopt local_options
    
    local backup_dir=$1
    local packages_dir
    packages_dir=$backup_dir/homebrew
    
    debug 2 "Storing Homebrew packages in: $packages_dir"
    
    info "Creating Homebrew packages directory: $packages_dir"
    mkdir -p $packages_dir || die "Failed to create Homebrew packages directory"
    
    info "Storing formula list..."
    debug 3 "Running: brew list --formula"
    brew list --formula >! $packages_dir/homebrew_packages_formula_before.txt || die "Failed to store formula list"
    debug 3 "Formula list stored in: $packages_dir/homebrew_packages_formula_before.txt"
    
    info "Storing cask list..."
    debug 3 "Running: brew list --cask"
    brew list --cask >! $packages_dir/homebrew_packages_cask_before.txt || die "Failed to store cask list"
    debug 3 "Cask list stored in: $packages_dir/homebrew_packages_cask_before.txt"
    
    success "Stored Homebrew package lists"
}

store_homebrew_changes() {
    emulate -L zsh
    setopt local_options
    
    local backup_dir=$1
    local packages_dir
    packages_dir=$backup_dir/homebrew
    
    debug 2 "Storing Homebrew changes in: $packages_dir"
    
    debug 3 "Running: brew list --formula (after)"
    brew list --formula >! $packages_dir/homebrew_packages_formula_after.txt
    debug 3 "Running: brew list --cask (after)"
    brew list --cask >! $packages_dir/homebrew_packages_cask_after.txt
    
    debug 2 "Comparing package lists to find changes..."
    # Find newly installed packages
    comm -13 $packages_dir/homebrew_packages_formula_before.txt $packages_dir/homebrew_packages_formula_after.txt >! $packages_dir/homebrew_packages_formula_added.txt
    comm -13 $packages_dir/homebrew_packages_cask_before.txt $packages_dir/homebrew_packages_cask_after.txt >! $packages_dir/homebrew_packages_cask_added.txt
    
    debug 3 "Changes stored in:"
    debug 3 "  - $packages_dir/homebrew_packages_formula_added.txt"
    debug 3 "  - $packages_dir/homebrew_packages_cask_added.txt"
}

show_homebrew_changes() {
    emulate -L zsh
    setopt local_options
    
    local backup_dir=$1
    local packages_dir formula_count cask_count response package
    packages_dir=$backup_dir/homebrew
    formula_count=0
    cask_count=0
    
    log "Checking Homebrew package changes"
    debug 2 "Looking for package changes in: $packages_dir"
    
    if [[ ! -f $packages_dir/homebrew_packages_formula_added.txt || ! -f $packages_dir/homebrew_packages_cask_added.txt ]]; then
        info "No package tracking information found"
        debug 2 "Package tracking files not found"
        return
    fi
    
    if [[ -s $packages_dir/homebrew_packages_formula_added.txt ]]; then
        formula_count=$(wc -l < $packages_dir/homebrew_packages_formula_added.txt)
        info "Found $formula_count formula packages that were installed:"
        debug 2 "Formula packages added: $formula_count"
        while read -r package; do
            print "    - $package"
            debug 3 "Formula package: $package"
        done < $packages_dir/homebrew_packages_formula_added.txt
    fi
    
    if [[ -s $packages_dir/homebrew_packages_cask_added.txt ]]; then
        cask_count=$(wc -l < $packages_dir/homebrew_packages_cask_added.txt)
        info "Found $cask_count cask packages that were installed:"
        debug 2 "Cask packages added: $cask_count"
        while read -r package; do
            print "    - $package"
            debug 3 "Cask package: $package"
        done < $packages_dir/homebrew_packages_cask_added.txt
    fi
    
    if (( formula_count > 0 || cask_count > 0 )); then
        print
        read "response?Would you like to remove these packages? [y/N] "
        debug 2 "User response for package removal: $response"
        if [[ $response =~ ^[Yy]$ ]]; then
            info "Removing packages..."
            
            if (( formula_count > 0 )); then
                debug 2 "Removing formula packages..."
                while read -r package; do
                    debug 3 "Removing formula: $package"
                    if brew uninstall --formula $package; then
                        success "Removed formula: $package"
                    else
                        error "Failed to remove formula: $package"
                        debug 3 "brew uninstall failed for formula: $package"
                    fi
                done < $packages_dir/homebrew_packages_formula_added.txt
            fi
            
            if (( cask_count > 0 )); then
                debug 2 "Removing cask packages..."
                while read -r package; do
                    debug 3 "Removing cask: $package"
                    if brew uninstall --cask $package; then
                        success "Removed cask: $package"
                    else
                        error "Failed to remove cask: $package"
                        debug 3 "brew uninstall failed for cask: $package"
                    fi
                done < $packages_dir/homebrew_packages_cask_added.txt
            fi
            
            success "Package cleanup completed"
            debug 2 "All requested packages have been removed"
        else
            info "Keeping installed packages"
            debug 2 "User chose to keep installed packages"
        fi
    else
        info "No package changes found"
        debug 2 "No package changes detected"
    fi
} 