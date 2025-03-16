#!/usr/bin/env zsh

emulate -L zsh
setopt err_exit no_unset pipe_fail

SCRIPT_DIR=${0:A:h}
source $SCRIPT_DIR/scripts/lib/common.zsh

usage() {
    cat << EOF
Usage: ${0:t} [options] BACKUP_DIR

Restore your system configuration from a backup.

Arguments:
    BACKUP_DIR    Path to the backup directory
                  (e.g., ~/.dotfiles_backup/20240321_123456)

Options:
    -h, --help                Show help message
    -v                        Enable verbose output
    -vv                       Enable more verbose output
    -vvv                      Enable most verbose output
    --no-homebrew-cleanup     Skip Homebrew package cleanup prompt
    --force                   Skip all confirmation prompts
    --dry-run                 Show what would be restored without making changes

Examples:
    ${0:t} ~/.dotfiles_backup/20240321_123456            # Normal restore
    ${0:t} --force ~/.dotfiles_backup/20240321_123456    # Restore without prompts
    ${0:t} --dry-run ~/.dotfiles_backup/20240321_123456  # Preview restore
    ${0:t} -v ~/.dotfiles_backup/20240321_123456         # Verbose restore
EOF
}

parse_args() {
    typeset -g NO_HOMEBREW_CLEANUP=0
    typeset -g FORCE=0
    typeset -g DRY_RUN=0
    typeset -g BACKUP_DIR=""

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
            --no-homebrew-cleanup)
                NO_HOMEBREW_CLEANUP=1
                shift
                ;;
            --force)
                FORCE=1
                shift
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            *)
                if [[ -z $BACKUP_DIR ]]; then
                    BACKUP_DIR=$1
                    debug 2 "Checking backup directory: $BACKUP_DIR"
                    [[ -d $BACKUP_DIR ]] || die "Error: Backup directory '$BACKUP_DIR' does not exist"
                    shift
                else
                    error "Unknown option: $1"
                    usage
                    exit 1
                fi
                ;;
        esac
    done

    debug 1 "Debug level set to $DEBUG_LEVEL"
    debug 1 "NO_HOMEBREW_CLEANUP=$NO_HOMEBREW_CLEANUP"
    debug 1 "FORCE=$FORCE"
    debug 1 "DRY_RUN=$DRY_RUN"
    debug 1 "BACKUP_DIR=$BACKUP_DIR"

    [[ -n $BACKUP_DIR ]] || { error "Error: Backup directory path is required"; usage; exit 1 }
}

restore_dotfiles() {
    log "Restoring dotfiles from backup"
    debug 2 "Source directory: $BACKUP_DIR"
    debug 2 "Target directory: $HOME"
    
    if (( DRY_RUN )); then
        log "DRY RUN: The following files would be restored:"
        debug 2 "Running in dry-run mode"
    else {
        if (( ! FORCE )); then
            print
            read "response?Are you sure you want to restore files from $BACKUP_DIR? [y/N] "
            debug 2 "User response for restore confirmation: $response"
            [[ $response =~ ^[Yy]$ ]] || die "Restore cancelled"
        } else {
            debug 2 "Force mode enabled, skipping confirmation"
        }
        
        debug 2 "Removing existing stow links..."
        STOW_DIR=$DOTFILES stow -D . 2>/dev/null || true
    }
    
    local source_dir=$BACKUP_DIR
    local target_dir=$HOME
    
    [[ -d $source_dir ]] || die "No files found in backup directory: $source_dir"
    
    local -a files
    debug 2 "Scanning backup directory for files..."
    files=($source_dir/*(ND))
    debug 3 "Found files:"
    (( DEBUG_LEVEL >= 3 )) && printf '  - %s\n' "${files[@]#$source_dir/}"
    
    for file in $files; do
        local relative_path=${file#$source_dir/}
        local target_path=$target_dir/$relative_path
        debug 2 "Processing: $relative_path"
        
        if (( DRY_RUN )); then
            info "Would restore: $relative_path"
            debug 3 "  From: $file"
            debug 3 "  To: $target_path"
        else {
            debug 3 "Creating parent directory: ${target_path:h}"
            mkdir -p ${target_path:h}
            debug 3 "Copying file from $file to $target_path"
            if cp -a $file $target_path; then
                info "Restored: $relative_path"
                debug 3 "File restored successfully"
            else {
                error "Failed to restore: $relative_path"
                debug 3 "cp command failed with status: $?"
            }
        }
    }
    
    if (( DRY_RUN )); then
        success "Dry run completed"
        debug 2 "Dry run simulation finished"
    else {
        success "Dotfiles restored from backup"
        debug 2 "All files processed from backup"
    }
}

main() {
    parse_args $@
    debug 1 "Starting restore process..."
    setup_env
    check_system
    install_xcode_tools
    restore_dotfiles
    
    if (( ! NO_HOMEBREW_CLEANUP )); then
        debug 2 "Running Homebrew package cleanup..."
        show_homebrew_changes $BACKUP_DIR
    else {
        info "Skipping Homebrew package cleanup (--no-homebrew-cleanup specified)"
        debug 2 "Homebrew cleanup skipped due to --no-homebrew-cleanup flag"
    }
    
    if (( DRY_RUN )); then
        success "Dry run completed!"
        debug 1 "Dry run process completed successfully"
    else {
        success "Restore completed!"
        info "You may need to restart your applications for changes to take effect"
        debug 1 "Restore process completed successfully"
    }
}

main $@ 