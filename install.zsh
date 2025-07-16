#!/usr/bin/env zsh

emulate -L zsh
setopt no_unset pipe_fail

SCRIPT_DIR=${0:A:h}
source $SCRIPT_DIR/scripts/lib/common.zsh

# Debug levels
typeset -g DEBUG_LEVEL=0

# Ensure cleanup runs on exit or interrupt
trap cleanup EXIT INT TERM

debug() {
    local level=$1
    shift
    if (( DEBUG_LEVEL >= level )); then
        # Add timestamp for most verbose level
        if (( DEBUG_LEVEL >= 3 )); then
            local timestamp=$(date "+%Y-%m-%d %H:%M:%S.%3N")
            print -P "  ${BLUE}debug[$level]${RESET} [$timestamp] $*"
        else
            print -P "  ${BLUE}debug[$level]${RESET}  $*"
        fi
    fi
}

usage() {
    cat << EOF
Usage: ${0:t} [options]

Install and configure your system using these dotfiles.

Options:
    -h, --help              Show help message
    -v                      Enable verbose output
    -vv                     Enable more verbose output
    -vvv                    Enable most verbose output
    --no-homebrew           Skip Homebrew installation and package management
    --no-macos-defaults     Skip setting macOS defaults
    --no-backup             Skip backing up existing files
    --no-services           Skip starting services (e.g., skhd)

Example:
    ${0:t}                 # Full installation
    ${0:t} --no-backup     # Install without backing up existing files
    ${0:t} -v             # Full installation with verbose output
EOF
}

parse_args() {
    typeset -g NO_HOMEBREW=0
    typeset -g NO_MACOS_DEFAULTS=0
    typeset -g NO_BACKUP=0
    typeset -g NO_SERVICES=0

    while (( $# )); do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v)
                DEBUG_LEVEL=1
                shift
                ;;
            -vv)
                DEBUG_LEVEL=2
                shift
                ;;
            -vvv)
                DEBUG_LEVEL=3
                shift
                ;;
            --no-homebrew)
                NO_HOMEBREW=1
                shift
                ;;
            --no-macos-defaults)
                NO_MACOS_DEFAULTS=1
                shift
                ;;
            --no-backup)
                NO_BACKUP=1
                shift
                ;;
            --no-services)
                NO_SERVICES=1
                shift
                ;;
            *)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    debug 1 "Debug level set to $DEBUG_LEVEL"
    debug 1 "NO_HOMEBREW=$NO_HOMEBREW"
    debug 1 "NO_MACOS_DEFAULTS=$NO_MACOS_DEFAULTS"
    debug 1 "NO_BACKUP=$NO_BACKUP"
    debug 1 "NO_SERVICES=$NO_SERVICES"
}

install_xcode_tools() {
    log "Checking Xcode Command Line Tools"
    debug 2 "Checking xcode-select path..."
    if ! xcode-select -p &> /dev/null; then
        info "Installing Xcode Command Line Tools..."
        debug 2 "Running xcode-select --install"
        xcode-select --install &> /dev/null || die "Failed to install Xcode Command Line Tools"
        
        until xcode-select -p &> /dev/null; do
            info "Waiting for Xcode Command Line Tools installation..."
            debug 3 "Checking xcode-select path again..."
            sleep 5
        done
    fi
    debug 2 "Xcode Command Line Tools path: $(xcode-select -p)"
    success "Xcode Command Line Tools are installed"
}

setup_dotfiles() {
    log "Setting up dotfiles repository"
    debug 2 "DOTFILES path: $DOTFILES"
    if [[ ! -d $DOTFILES ]]; then
        info "Cloning dotfiles repository..."
        debug 2 "Cloning from: https://github.com/adamNewell/dotfiles.git"
        debug 2 "Cloning to: $DOTFILES"
        git clone https://github.com/adamNewell/dotfiles.git $DOTFILES || die "Failed to clone dotfiles repository"
        cd $DOTFILES || die "Failed to enter dotfiles directory"
        debug 3 "Current directory: $(pwd)"
    else
        debug 2 "Dotfiles repository already exists at $DOTFILES"
    fi
}

backup_existing_files() {
    # Enable err_exit only for this function and disable it for critical operations
    setopt localoptions err_exit
    
    log "Backing up existing files"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir=$HOME/.dotfiles_backup/$timestamp
    
    debug 2 "Timestamp: $timestamp"
    debug 2 "Backup directory: $backup_dir"
    debug 2 "Current shell: $SHELL"
    debug 2 "Current directory: $(pwd)"
    debug 2 "DOTFILES absolute path: ${DOTFILES:A}"
    
    # Temporarily disable err_exit for critical operations
    setopt localoptions
    unsetopt err_exit
    
    info "Creating backup directory: $backup_dir"
    if ! mkdir -p $backup_dir; then
        local status=$?
        debug 3 "mkdir failed with status: $status"
        debug 3 "Error message: $(mkdir -p $backup_dir 2>&1)"
        debug 3 "Parent directory exists: $([[ -e "${backup_dir:h}" ]] && echo "yes" || echo "no")"
        debug 3 "Parent directory writable: $([[ -w "${backup_dir:h}" ]] && echo "yes" || echo "no")"
        error "Failed to create backup directory"
        return 1
    fi
    debug 3 "Created backup directory with permissions: $(ls -la $backup_dir)"
    
    info "Storing Homebrew packages..."
    debug 2 "Calling store_homebrew_packages with backup_dir: $backup_dir"
    if ! store_homebrew_packages $backup_dir; then
        debug 3 "store_homebrew_packages failed with status: $?"
        die "Failed to store Homebrew packages"
    fi
    
    info "Starting file backup..."
    
    # First, find all .config directories in our dotfiles that we'll be stowing
    local -a config_dirs=()
    if [[ -d "$DOTFILES/.config" ]]; then
        debug 2 "Scanning $DOTFILES/.config for directories..."
        debug 3 "Dotfiles .config permissions: $(ls -la $DOTFILES/.config)"
        for dir in "$DOTFILES/.config"/*(/); do
            debug 3 "Found config directory: ${dir:t} (${dir:A})"
            config_dirs+=("$HOME/.config/${dir:t}")
        done
    fi
    
    # Add other common files to back up
    local -a files=(
        $HOME/.viminfo
        $HOME/.zsh_history
        $HOME/.gitconfig
        ${config_dirs[@]}
    )
    
    debug 2 "Files to check for backup:"
    (( DEBUG_LEVEL >= 2 )) && printf '  - %s\n' "${files[@]}"
    
    local backed_up=0
    local zsh_handled=0
    
    # Handle zsh config separately since we need it to run the script
    if [[ -e $HOME/.config/zsh ]]; then
        info "Processing: $HOME/.config/zsh"
        local zsh_backup=$backup_dir/.config/zsh
        debug 2 "Copying zsh config to: $zsh_backup"
        debug 3 "zsh config permissions: $(ls -la $HOME/.config/zsh)"
        debug 3 "zsh config real path: ${HOME:A}/.config/zsh"
        
        # Check if it's a symlink to our dotfiles
        if [[ -L "$HOME/.config/zsh" ]]; then
            local link_target=$(readlink "$HOME/.config/zsh")
            local abs_link_target=${link_target:A}
            debug 3 "zsh config is a symlink pointing to: $link_target"
            debug 3 "zsh config absolute target: $abs_link_target"
            debug 3 "DOTFILES absolute path for comparison: ${DOTFILES:A}"
            
            if [[ $abs_link_target == *"${DOTFILES:A}"* ]]; then
                debug 2 "zsh config already points to our dotfiles, skipping backup"
                debug 3 "Link target ($abs_link_target) contains dotfiles path (${DOTFILES:A})"
                zsh_handled=1
            else
                debug 2 "zsh config points elsewhere, will back up target"
                debug 3 "Link target ($abs_link_target) does not contain dotfiles path (${DOTFILES:A})"
            fi
        else
            debug 3 "zsh config is not a symlink"
        fi
        
        if [[ $zsh_handled -eq 0 ]]; then
            if mkdir -p ${zsh_backup:h}; then
                debug 3 "Created backup parent directory: ${zsh_backup:h}"
                debug 3 "Backup parent directory permissions: $(ls -la ${zsh_backup:h})"
                # Use cp -R for directories since we're on macOS
                if cp -R "$HOME/.config/zsh" "${zsh_backup%/*}/"; then
                    info "Backed up: $HOME/.config/zsh (copied)"
                    (( backed_up++ ))
                    zsh_handled=1
                    debug 3 "Backup successful, incremented count to $backed_up"
                    debug 3 "Backup permissions: $(ls -la $zsh_backup)"
                    debug 3 "Note: Not removing zsh config as it's needed for the script"
                else
                    local status=$?
                    debug 3 "Failed to backup zsh config: cp returned $status"
                    debug 3 "Current process info: $(ps -p $$ -o command=)"
                    debug 3 "Source exists: $([[ -e "$HOME/.config/zsh" ]] && echo "yes" || echo "no")"
                    debug 3 "Source readable: $([[ -r "$HOME/.config/zsh" ]] && echo "yes" || echo "no")"
                    debug 3 "Target parent writable: $([[ -w "${zsh_backup%/*}" ]] && echo "yes" || echo "no")"
                    error "Failed to backup zsh config"
                    return 1
                fi
            else
                local status=$?
                debug 3 "Failed to create backup directory: mkdir returned $status"
                debug 3 "Parent directory exists: $([[ -e "${zsh_backup:h:h}" ]] && echo "yes" || echo "no")"
                debug 3 "Parent directory writable: $([[ -w "${zsh_backup:h:h}" ]] && echo "yes" || echo "no")"
                error "Failed to create backup directory for zsh config"
                return 1
            fi
        fi
    else
        info "Skipping non-existent file: $HOME/.config/zsh"
        debug 2 "zsh config not found at $HOME/.config/zsh"
        debug 3 "Parent directory exists: $([[ -e "$HOME/.config" ]] && echo "yes" || echo "no")"
    fi
    
    for file in $files; do
        debug 2 "Processing file: $file"
        debug 3 "File real path: ${file:A}"
        debug 3 "Current status: backed_up=$backed_up, zsh_handled=$zsh_handled"
        
        # Skip zsh config if we already handled it
        if [[ $file == "$HOME/.config/zsh" && $zsh_handled -eq 1 ]]; then
            debug 2 "Skipping zsh config as it was already handled"
            continue
        fi
        
        if [[ -e $file || -L $file ]]; then
            info "Processing: $file"
            local target_path=$backup_dir${file#$HOME}
            debug 3 "Target backup path: $target_path"
            debug 3 "File permissions: $(ls -la $file)"
            debug 3 "File type: $(stat -f "%HT" $file)"
            debug 3 "Parent directory exists: $([[ -e "${target_path:h}" ]] && echo "yes" || echo "no")"
            debug 3 "Parent directory writable: $([[ -w "${target_path:h}" ]] && echo "yes" || echo "no")"
            
            # Check if it's a symlink to our dotfiles
            if [[ -L $file ]]; then
                local link_target=$(readlink "$file")
                local abs_link_target=${link_target:A}
                debug 3 "File is a symlink pointing to: $link_target"
                debug 3 "Absolute link target: $abs_link_target"
                debug 3 "DOTFILES path for comparison: ${DOTFILES:A}"
                
                if [[ $abs_link_target == *"${DOTFILES:A}"* ]]; then
                    debug 2 "File points to our dotfiles, copying actual content instead of symlink"
                    debug 3 "Will copy from: $abs_link_target"
                else
                    debug 3 "Link target ($abs_link_target) does not contain dotfiles path (${DOTFILES:A})"
                fi
            fi
            
            # Create parent directory for backup if it doesn't exist
            if [[ ! -d ${target_path:h} ]]; then
                debug 3 "Creating backup parent directory: ${target_path:h}"
                debug 3 "Parent exists: $([[ -e "${target_path:h:h}" ]] && echo "yes" || echo "no")"
                if ! mkdir -p "${target_path:h}"; then
                    local status=$?
                    debug 3 "Failed to create backup directory: mkdir returned $status"
                    debug 3 "Parent directory permissions: $(ls -la ${target_path:h:h} 2>/dev/null || echo 'cannot access')"
                    debug 3 "Parent directory writable: $([[ -w "${target_path:h:h}" ]] && echo "yes" || echo "no")"
                    error "Failed to create backup directory for: $file"
                    return 1
                fi
                debug 3 "Created directory with permissions: $(ls -la ${target_path:h})"
            fi
            
            # If it's a directory or symlink to a directory, use cp -RL to follow symlinks
            # If it's a regular file or symlink to a file, use cp -L to follow symlinks
            if [[ -d $file || (-L $file && -d $(readlink -f $file 2>/dev/null || echo "")) ]]; then
                debug 3 "Target is a directory (or symlink to directory), copying with cp -RL"
                debug 3 "Source directory contents: $(ls -la $file)"
                debug 3 "Attempting to copy directory..."
                if cp -RL "$file" "${target_path%/*}/"; then
                    info "Backed up: $file (copied with contents)"
                    (( backed_up++ ))
                    debug 3 "Backup successful, incremented count to $backed_up"
                    debug 3 "Backup contents: $(ls -la ${target_path})"
                    debug 3 "Original file before removal: $(ls -la $file)"
                    debug 3 "Original file parent directory: $(ls -la ${file%/*})"
                    
                    # Remove the original after successful copy, but skip zsh config
                    if [[ $file != "$HOME/.config/zsh" ]]; then
                        debug 3 "Attempting to remove original: $file"
                        debug 3 "File type before removal: $(stat -f "%HT" "$file")"
                        debug 3 "File permissions before removal: $(ls -la "$file")"
                        
                        # Temporarily disable err_exit for the removal operation
                        setopt localoptions
                        unsetopt err_exit
                        
                        if [[ -L "$file" ]]; then
                            debug 3 "Removing symlink with rm -f"
                            debug 3 "Symlink target before removal: $(readlink "$file")"
                            rm -f "$file"
                            local rm_status=$?
                            debug 3 "rm command exit status: $rm_status"
                            
                            if (( rm_status != 0 )); then
                                debug 3 "Failed to remove symlink: rm returned $rm_status"
                                debug 3 "Error message: $(rm -f "$file" 2>&1)"
                                debug 3 "Symlink still exists: $([[ -L "$file" ]] && echo "yes" || echo "no")"
                                debug 3 "Symlink permissions: $(ls -la $file)"
                                debug 3 "Parent directory writable: $([[ -w "${file%/*}" ]] && echo "yes" || echo "no")"
                                debug 3 "Parent directory permissions: $(ls -la ${file%/*})"
                                debug 3 "Current working directory: $(pwd)"
                                debug 3 "Process status: $(ps -p $$ -o pid,ppid,pgid,command=)"
                                error "Failed to remove original symlink: $file"
                                return 1
                            fi
                        else
                            debug 3 "Removing directory/file with rm -rf"
                            rm -rf "$file"
                            local rm_status=$?
                            debug 3 "rm command exit status: $rm_status"
                            
                            if (( rm_status != 0 )); then
                                debug 3 "Failed to remove original: rm returned $rm_status"
                                debug 3 "Error message: $(rm -rf "$file" 2>&1)"
                                debug 3 "File permissions before removal: $(ls -la $file)"
                                debug 3 "Parent directory writable: $([[ -w "${file%/*}" ]] && echo "yes" || echo "no")"
                                debug 3 "Parent directory permissions: $(ls -la ${file%/*})"
                                debug 3 "Current working directory: $(pwd)"
                                debug 3 "Process status: $(ps -p $$ -o pid,ppid,pgid,command=)"
                                error "Failed to remove original: $file"
                                return 1
                            fi
                        fi
                        
                        # Re-enable err_exit
                        setopt err_exit
                        
                        debug 3 "Checking if removal was successful"
                        if [[ -e "$file" ]]; then
                            debug 3 "Warning: File still exists after removal"
                            debug 3 "File status: $(ls -la "$file" 2>&1)"
                            debug 3 "Current working directory: $(pwd)"
                            debug 3 "Process status: $(ps -p $$ -o pid,ppid,pgid,command=)"
                            error "Failed to remove file that should have been removed: $file"
                            return 1
                        else
                            debug 3 "Successfully removed original: $file"
                        fi
                    else
                        debug 3 "Skipping removal of zsh config as it's needed"
                    fi
                    debug 3 "Moving to next file after backup and removal operations"
                    debug 3 "Current working directory: $(pwd)"
                    debug 3 "Next file to process: ${files[$((${files[(i)$file]} + 1))]}"
                else
                    local status=$?
                    debug 3 "Failed to backup directory: cp returned $status"
                    debug 3 "Source permissions: $(ls -la $file)"
                    debug 3 "Source readable: $([[ -r "$file" ]] && echo "yes" || echo "no")"
                    debug 3 "Target permissions: $(ls -la ${target_path:h})"
                    debug 3 "Target writable: $([[ -w "${target_path:h}" ]] && echo "yes" || echo "no")"
                    error "Failed to backup: $file"
                    return 1
                fi
            else
                debug 3 "Target is a file (or symlink to file), copying with cp -L"
                debug 3 "Attempting to copy file..."
                if cp -L "$file" "$target_path"; then
                    info "Backed up: $file (copied content)"
                    (( backed_up++ ))
                    debug 3 "Backup successful, incremented count to $backed_up"
                    debug 3 "Backup file permissions: $(ls -la $target_path)"
                    # Remove original after successful copy
                    if ! rm -f "$file"; then
                        local status=$?
                        debug 3 "Failed to remove original after backup: rm returned $status"
                        debug 3 "File permissions before removal: $(ls -la $file)"
                        debug 3 "File writable: $([[ -w "$file" ]] && echo "yes" || echo "no")"
                        error "Failed to remove original after backup: $file"
                        return 1
                    fi
                    debug 3 "Successfully removed original: $file"
                else
                    local status=$?
                    debug 3 "Failed to backup file: cp returned $status"
                    debug 3 "Source permissions: $(ls -la $file)"
                    debug 3 "Source readable: $([[ -r "$file" ]] && echo "yes" || echo "no")"
                    debug 3 "Target permissions: $(ls -la ${target_path:h})"
                    debug 3 "Target writable: $([[ -w "${target_path:h}" ]] && echo "yes" || echo "no")"
                    error "Failed to backup: $file"
                    return 1
                fi
            fi
        else
            info "Skipping non-existent file: $file"
            debug 2 "File does not exist: $file"
            debug 3 "Parent directory exists: $([[ -e "${file:h}" ]] && echo "yes" || echo "no")"
        fi
        debug 3 "Completed processing file: $file"
    done
    
    # At the end of the function, before success messages
    debug 3 "Backup function completing"
    debug 3 "Current working directory: $(pwd)"
    debug 3 "Process status: $(ps -p $$ -o pid,ppid,pgid,command=)"
    
    if (( backed_up > 0 )); then
        success "Backed up $backed_up existing files to: $backup_dir"
        debug 2 "Total files backed up: $backed_up"
        debug 3 "Final backup directory contents: $(ls -la $backup_dir)"
    else
        info "No existing files needed backup"
        debug 2 "No files required backup"
    fi
    
    info "Setting BACKUP_DIR variable"
    typeset -g BACKUP_DIR=$backup_dir
    debug 2 "BACKUP_DIR set to: $backup_dir"
    success "Backup completed successfully"
    info "Backup phase complete, proceeding with installation"
    return 0
}

init_submodules() {
    log 'Initializing git submodules'
    debug 2 "Running git submodule init"
    git submodule init || die 'Failed to initialize git submodules'
    debug 2 "Running git submodule update"
    git submodule update --init --recursive || die 'Failed to update git submodules'
    (( DEBUG_LEVEL >= 3 )) && git submodule status
    success 'Git submodules initialized and updated'
}

install_homebrew() {
    log 'Checking Homebrew installation'
    debug 2 "Checking for brew command..."
    if ! command -v brew &> /dev/null; then
        info 'Installing Homebrew'
        debug 2 "Downloading and running Homebrew install script..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || die 'Failed to install Homebrew'

        debug 2 "Setting up Homebrew environment..."
        eval "$(/opt/homebrew/bin/brew shellenv)"
        success 'Homebrew installed'
    else
        success 'Homebrew already installed'
        debug 2 "Homebrew path: $(which brew)"
        debug 3 "Homebrew version: $(brew --version)"
    fi

    info 'Updating Homebrew'
    debug 2 "Running brew update..."
    brew update || die 'Failed to update Homebrew'
    
    info 'Upgrading existing packages'
    debug 2 "Running brew upgrade..."
    brew upgrade || die 'Failed to upgrade Homebrew packages'
    
    success 'Homebrew is ready'
}

install_homebrew_packages() {
    log 'Installing Homebrew packages'
    local brewfile="packages/brew/Brewfile"
    debug 2 "Using Brewfile: $brewfile"
    
    debug 2 "Checking Brewfile dependencies..."
    if brew bundle check --file=$brewfile; then
        success 'Brewfile dependencies are satisfied'
        debug 2 "All dependencies already installed"
    else
        info 'Installing Brewfile dependencies...'
        debug 2 "Installing missing dependencies..."
        debug 3 "Missing formulae: $(brew bundle check --file=$brewfile 2>&1)"
        brew bundle --file=$brewfile || die 'Failed to install Brewfile dependencies'
        success 'Brewfile dependencies installed'
    fi
}

setup_stow() {
    log 'Setting up GNU Stow'
    debug 2 "Checking for stow command..."
    if ! command -v stow &> /dev/null; then
        debug 2 "stow not found"
        die "GNU Stow is not installed. Please install it first (brew install stow)"
    else
        debug 2 "stow found at: $(which stow)"
        debug 3 "stow version: $(stow --version)"
    fi
}

install_dotfiles() {
    log 'Installing dotfiles using GNU Stow'
    
    # First, check for conflicts
    info "Checking for conflicts..."
    debug 2 "Running stow --no --verbose to check for conflicts..."
    local conflicts=$(STOW_DIR=$DOTFILES stow --no --verbose . 2>&1)
    debug 3 "Stow conflict check output:"
    debug 3 "$conflicts"
    
    # Extract both existing targets and not-owned-by-stow conflicts
    local existing_targets=$(echo "$conflicts" | grep 'existing target' | awk -F': ' '{print $2}')
    local not_owned=$(echo "$conflicts" | grep 'not owned by stow' | sed 's/.*existing target is not owned by stow: //')
    
    if [[ -n $existing_targets || -n $not_owned ]]; then
        info "Found conflicting files/directories:"
        debug 2 "Conflicts found"
        
        # Handle existing targets
        if [[ -n $existing_targets ]]; then
            debug 2 "Processing existing target conflicts..."
            echo "$existing_targets" | while read -r file; do
                [[ -z $file ]] && continue
                info "  - $file (existing target)"
                debug 3 "Conflict details for $file: $(ls -la "$HOME/$file" 2>/dev/null)"
            done
        fi
        
        # Handle not-owned-by-stow targets
        if [[ -n $not_owned ]]; then
            debug 2 "Processing not-owned-by-stow conflicts..."
            echo "$not_owned" | while read -r file; do
                [[ -z $file ]] && continue
                info "  - $file (not owned by stow)"
                debug 3 "Conflict details for $file: $(ls -la "$HOME/$file" 2>/dev/null)"
                if [[ -L "$HOME/$file" ]]; then
                    local link_target=$(readlink "$HOME/$file")
                    debug 3 "Symlink points to: $link_target"
                fi
            done
        fi
        
        info "Backing up and removing conflicting files..."
        
        # Process all conflicts
        {
            echo "$existing_targets"
            echo "$not_owned"
        } | sort -u | while read -r file; do
            [[ -z $file ]] && continue
            if [[ -e "$HOME/$file" || -L "$HOME/$file" ]]; then
                # Check if it's a symlink pointing somewhere in our dotfiles
                if [[ -L "$HOME/$file" ]]; then
                    local link_target=$(readlink "$HOME/$file")
                    debug 2 "Found symlink: $file -> $link_target"
                    
                    # If it points somewhere in our dotfiles, just remove it
                    if [[ $link_target == *"$DOTFILES"* ]]; then
                        debug 2 "Removing existing symlink that points to our dotfiles"
                        rm "$HOME/$file"
                        continue
                    fi
                fi
                
                local backup_path="$HOME/$file.backup-$(date +%Y%m%d_%H%M%S)"
                debug 2 "Backing up $HOME/$file to $backup_path"
                
                # Create parent directory for backup if it doesn't exist
                if [[ ! -d ${backup_path:h} ]]; then
                    debug 3 "Creating backup parent directory: ${backup_path:h}"
                    mkdir -p "${backup_path:h}"
                fi
                
                # Backup the file/directory
                if mv "$HOME/$file" "$backup_path"; then
                    success "Backed up $file to ${backup_path##*/}"
                    
                    # If it's a directory, ensure it's completely removed
                    if [[ -d "$HOME/$file" ]]; then
                        debug 2 "Removing directory: $HOME/$file"
                        rm -rf "$HOME/$file"
                    fi
                    
                    # Create parent directory for stow
                    debug 3 "Creating parent directory for stow: ${HOME}/${file:h}"
                    mkdir -p "${HOME}/${file:h}"
                else
                    error "Failed to backup $file"
                    debug 3 "mv command failed with status: $?"
                    return 1
                fi
            fi
        done
    else
        debug 2 "No conflicts found"
    fi
    
    # Clean up any existing stow links
    info "Cleaning up existing stow links..."
    debug 2 "Running stow -D to remove existing links..."
    STOW_DIR=$DOTFILES stow -D . 2>/dev/null || true

    info "Stowing dotfiles"
    debug 2 "Running stow to create new links..."
    
    # Stow .config directory contents into .config
    if STOW_DIR=$DOTFILES/.config stow -v -t $HOME/.config --adopt .; then
        debug 3 "Successfully stowed .config directory contents"
    else
        debug 3 "Failed to stow .config directory contents"
        die "Failed to stow .config directory contents"
    fi

    # Stow .local directory contents into .local
    if STOW_DIR=$DOTFILES/.local stow -v -t $HOME/.local .; then
        debug 3 "Successfully stowed .local directory contents"
        success "Dotfiles stowed successfully"
        debug 3 "Stow operation completed successfully"
    else
        debug 3 "Stow operation failed"
        die "Failed to stow dotfiles"
    fi
}

setup_env() {
    # Create our own temporary directory
    debug 2 "Creating temporary directory..."
    export SCRIPT_TMPDIR=$(mktemp -d)
    debug 2 "SCRIPT_TMPDIR: $SCRIPT_TMPDIR"
    
    debug 2 "Setting up environment variables..."
    export DOTFILES=${DOTFILES:-$HOME/.dotfiles}
    export STOW_DIR=${STOW_DIR:-$DOTFILES}
    debug 2 "DOTFILES: $DOTFILES"
    debug 2 "STOW_DIR: $STOW_DIR"
}

main() {
    parse_args $@
    debug 1 "Starting installation process..."
    
    # Wrap main operations in error handling
    {
        setup_env
        check_system
        install_xcode_tools
        setup_dotfiles
        
        if (( ! NO_BACKUP )); then
            info "Starting backup phase..."
            if ! backup_existing_files; then
                debug 3 "backup_existing_files failed"
                die "Backup phase failed"
            fi
            success "Backup phase completed"
        else
            info "Skipping backup (--no-backup specified)"
            debug 2 "Backup phase skipped due to --no-backup flag"
        fi
        
        if (( ! NO_HOMEBREW )); then
            info "Starting Homebrew phase..."
            install_homebrew
            install_homebrew_packages
            [[ -n $BACKUP_DIR ]] && store_homebrew_changes $BACKUP_DIR
            success "Homebrew phase completed"
        else
            info "Skipping Homebrew installation (--no-homebrew specified)"
            debug 2 "Homebrew phase skipped due to --no-homebrew flag"
        fi
        
        info "Starting git submodules phase..."
        init_submodules
        success "Git submodules phase completed"
        
        info "Starting stow phase..."
        setup_stow
        install_dotfiles
        success "Stow phase completed"
        
        if (( ! NO_MACOS_DEFAULTS )); then
            info "Starting macOS defaults phase..."
            log 'Setting reasonable MacOS defaults...'
            debug 2 "Sourcing macOS defaults script..."
            source ./packages/macos/scripts/defaults.sh
            success "MacOS defaults phase completed"
        else
            info "Skipping macOS defaults (--no-macos-defaults specified)"
            debug 2 "macOS defaults phase skipped due to --no-macos-defaults flag"
        fi
        
        if (( ! NO_SERVICES )); then
            info "Starting services phase..."
            debug 2 "Starting skhd service..."
            skhd --start-service || die 'Failed to start skhd service'
            success "Services phase completed"
        else
            info "Skipping service startup (--no-services specified)"
            debug 2 "Services phase skipped due to --no-services flag"
        fi
        
        success 'All installed!'
        info 'You will need to restart your machine for all changes to take effect'
        debug 1 "Installation process completed successfully"
    } || {
        local status=$?
        debug 3 "Error occurred in main function"
        debug 3 "Exit status: $status"
        debug 3 "Current working directory: $(pwd)"
        debug 3 "Process status: $(ps -p $$ -o pid,ppid,pgid,command=)"
        die "Installation failed"
    }
}

main $@ 