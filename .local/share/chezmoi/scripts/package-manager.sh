#!/bin/bash
# Advanced package management with dependency resolution and rollback
# This script provides utilities for managing the simplified package system

set -e
set -o pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}" >&2; }

# State tracking
readonly STATE_DIR="${HOME}/.local/state/dotfiles"
readonly INSTALL_LOG="${STATE_DIR}/install.log"
readonly VERSION_LOCK="${STATE_DIR}/versions.lock"
readonly BACKUP_DIR="${STATE_DIR}/backups"

# Ensure state directory exists
mkdir -p "${STATE_DIR}" "${BACKUP_DIR}"

# Dependency graph (simplified)
declare -A DEPENDENCIES=(
    ["git"]="curl"
    ["tmux"]="zsh"
    ["neovim"]="git"
    ["delta"]="git"
    ["oh-my-posh"]="zsh"
    ["sheldon"]="zsh git"
    ["fzf"]="fd ripgrep"
    ["zoxide"]="fzf"
)

# Version constraints
declare -A MIN_VERSIONS=(
    ["git"]="2.30.0"
    ["zsh"]="5.8.0"
    ["python3"]="3.10.0"
    ["node"]="18.0.0"
)

# Log installation activity
log_action() {
    local action="$1"
    local package="$2"
    local version="$3"
    local status="$4"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${action} ${package} ${version} ${status}" >> "${INSTALL_LOG}"
}

# Create version lock file
create_version_lock() {
    info "Creating version lock file..."
    
    cat > "${VERSION_LOCK}" << 'EOF'
# Package version lock file
# Generated automatically - do not edit manually
# Format: package_name=version_string

EOF
    
    # Record versions of installed tools
    local tools=("git" "zsh" "tmux" "neovim" "node" "python3" "mise")
    
    for tool in "${tools[@]}"; do
        if command -v "${tool}" >/dev/null 2>&1; then
            local version=""
            case "${tool}" in
                "git") version=$(git --version | awk '{print $3}') ;;
                "zsh") version=$(zsh --version | awk '{print $2}') ;;
                "tmux") version=$(tmux -V | awk '{print $2}') ;;
                "neovim") version=$(nvim --version | head -n1 | awk '{print $2}') ;;
                "node") version=$(node --version | sed 's/v//') ;;
                "python3") version=$(python3 --version | awk '{print $2}') ;;
                "mise") version=$(mise --version) ;;
            esac
            
            if [[ -n "${version}" ]]; then
                echo "${tool}=${version}" >> "${VERSION_LOCK}"
                log_action "LOCK" "${tool}" "${version}" "SUCCESS"
            fi
        fi
    done
    
    success "Version lock file created at ${VERSION_LOCK}"
}

# Check version constraints
check_version_constraint() {
    local package="$1"
    local current_version="$2"
    local min_version="${MIN_VERSIONS[$package]:-}"
    
    if [[ -z "${min_version}" ]]; then
        return 0  # No constraint
    fi
    
    # Simple version comparison (works for most semantic versions)
    if printf '%s\n%s\n' "${min_version}" "${current_version}" | sort -V | head -n1 | grep -q "^${min_version}$"; then
        return 0  # Version meets minimum requirement
    else
        return 1  # Version too old
    fi
}

# Resolve dependencies for a package
resolve_dependencies() {
    local package="$1"
    local resolved=()
    local to_process=("${package}")
    
    while [[ ${#to_process[@]} -gt 0 ]]; do
        local current="${to_process[0]}"
        to_process=("${to_process[@]:1}")  # Remove first element
        
        # Skip if already resolved
        if [[ " ${resolved[*]} " =~ " ${current} " ]]; then
            continue
        fi
        
        # Add to resolved list
        resolved+=("${current}")
        
        # Add dependencies to process list
        local deps="${DEPENDENCIES[$current]:-}"
        if [[ -n "${deps}" ]]; then
            read -ra dep_array <<< "${deps}"
            for dep in "${dep_array[@]}"; do
                if [[ ! " ${resolved[*]} " =~ " ${dep} " ]]; then
                    to_process+=("${dep}")
                fi
            done
        fi
    done
    
    # Print in dependency order (reverse of discovery order)
    local ordered=()
    for ((i=${#resolved[@]}-1; i>=0; i--)); do
        ordered+=("${resolved[i]}")
    done
    
    printf '%s\n' "${ordered[@]}"
}

# Create backup point
create_backup() {
    local backup_name="${1:-$(date '+%Y%m%d_%H%M%S')}"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    info "Creating backup point: ${backup_name}"
    mkdir -p "${backup_path}"
    
    # Backup current versions
    if [[ -f "${VERSION_LOCK}" ]]; then
        cp "${VERSION_LOCK}" "${backup_path}/versions.lock.backup"
    fi
    
    # Backup install log
    if [[ -f "${INSTALL_LOG}" ]]; then
        cp "${INSTALL_LOG}" "${backup_path}/install.log.backup"
    fi
    
    # Create backup manifest
    cat > "${backup_path}/manifest.txt" << EOF
Backup created: $(date)
System: $(uname -a)
User: $(whoami)
Hostname: $(hostname)
EOF
    
    log_action "BACKUP" "system" "${backup_name}" "SUCCESS"
    success "Backup created at ${backup_path}"
    echo "${backup_path}"
}

# Rollback to a backup point
rollback_to_backup() {
    local backup_name="$1"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    if [[ ! -d "${backup_path}" ]]; then
        error "Backup not found: ${backup_name}"
        return 1
    fi
    
    warn "Rolling back to backup: ${backup_name}"
    warn "This will restore package versions from the backup point"
    
    # Restore version lock
    if [[ -f "${backup_path}/versions.lock.backup" ]]; then
        cp "${backup_path}/versions.lock.backup" "${VERSION_LOCK}"
        info "Restored version lock file"
    fi
    
    log_action "ROLLBACK" "system" "${backup_name}" "SUCCESS"
    success "Rollback completed"
    warn "Note: This only restores tracking files. You may need to manually reinstall packages."
}

# List available backups
list_backups() {
    info "Available backups:"
    
    if [[ ! -d "${BACKUP_DIR}" ]] || [[ -z "$(ls -A "${BACKUP_DIR}" 2>/dev/null)" ]]; then
        warn "No backups found"
        return 0
    fi
    
    for backup in "${BACKUP_DIR}"/*; do
        if [[ -d "${backup}" ]]; then
            local backup_name=$(basename "${backup}")
            local manifest="${backup}/manifest.txt"
            
            echo "  📦 ${backup_name}"
            if [[ -f "${manifest}" ]]; then
                echo "     $(grep "Backup created:" "${manifest}" | cut -d' ' -f3-)"
            fi
        fi
    done
}

# Validate system health
validate_system() {
    info "Validating system health..."
    local issues=()
    
    # Check critical tools
    local critical_tools=("git" "zsh" "curl")
    for tool in "${critical_tools[@]}"; do
        if ! command -v "${tool}" >/dev/null 2>&1; then
            issues+=("Missing critical tool: ${tool}")
        fi
    done
    
    # Check version constraints
    if [[ -f "${VERSION_LOCK}" ]]; then
        while IFS='=' read -r package version; do
            if [[ -n "${package}" && -n "${version}" ]] && [[ ! "${package}" =~ ^# ]]; then
                if ! check_version_constraint "${package}" "${version}"; then
                    issues+=("${package} version ${version} does not meet minimum requirement")
                fi
            fi
        done < "${VERSION_LOCK}"
    fi
    
    # Report results
    if [[ ${#issues[@]} -eq 0 ]]; then
        success "System validation passed"
        return 0
    else
        error "System validation failed:"
        printf '  - %s\n' "${issues[@]}"
        return 1
    fi
}

# Show usage
show_usage() {
    cat << 'EOF'
Package Manager Utility

Usage: package-manager.sh <command> [options]

Commands:
  dependencies <package>     Show dependency resolution order for package
  backup [name]             Create a backup point
  rollback <name>           Rollback to a backup point
  list-backups              List available backup points
  validate                  Validate system health
  lock                      Create/update version lock file
  
Examples:
  package-manager.sh dependencies fzf
  package-manager.sh backup pre-update
  package-manager.sh rollback 20240715_143022
  package-manager.sh validate

State files are stored in: ~/.local/state/dotfiles/
EOF
}

# Main function
main() {
    local command="${1:-}"
    
    case "${command}" in
        "dependencies"|"deps")
            local package="${2:-}"
            if [[ -z "${package}" ]]; then
                error "Package name required"
                exit 1
            fi
            info "Dependency resolution order for ${package}:"
            resolve_dependencies "${package}"
            ;;
        "backup")
            local backup_name="${2:-}"
            create_backup "${backup_name}"
            ;;
        "rollback")
            local backup_name="${2:-}"
            if [[ -z "${backup_name}" ]]; then
                error "Backup name required"
                list_backups
                exit 1
            fi
            rollback_to_backup "${backup_name}"
            ;;
        "list-backups"|"backups")
            list_backups
            ;;
        "validate"|"check")
            validate_system
            ;;
        "lock")
            create_version_lock
            ;;
        "help"|"-h"|"--help"|"")
            show_usage
            ;;
        *)
            error "Unknown command: ${command}"
            show_usage
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"