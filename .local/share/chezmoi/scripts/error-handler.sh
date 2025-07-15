#!/bin/bash
# Comprehensive error handling utilities for dotfiles scripts
# Source this file to enable advanced error handling

# Colors for error output
readonly ERR_RED='\033[0;31m'
readonly ERR_YELLOW='\033[1;33m'
readonly ERR_BLUE='\033[0;34m'
readonly ERR_NC='\033[0m'

# Error handling configuration
DOTFILES_ERROR_LOG="${HOME}/.local/state/dotfiles/error.log"
DOTFILES_DEBUG_MODE="${DOTFILES_DEBUG:-false}"
DOTFILES_STRICT_MODE="${DOTFILES_STRICT:-true}"

# Ensure error log directory exists
mkdir -p "$(dirname "${DOTFILES_ERROR_LOG}")"

# Error logging function
log_error() {
    local level="$1"
    local message="$2"
    local line="${3:-unknown}"
    local function_name="${4:-main}"
    local script="${5:-${BASH_SOURCE[1]##*/}}"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="${timestamp} [${level}] ${script}:${function_name}:${line} - ${message}"
    
    # Log to file
    echo "${log_entry}" >> "${DOTFILES_ERROR_LOG}"
    
    # Also output to stderr with color
    case "${level}" in
        "ERROR")   echo -e "${ERR_RED}❌ ${message}${ERR_NC}" >&2 ;;
        "WARN")    echo -e "${ERR_YELLOW}⚠️  ${message}${ERR_NC}" >&2 ;;
        "INFO")    echo -e "${ERR_BLUE}ℹ️  ${message}${ERR_NC}" >&2 ;;
        "DEBUG")   [[ "${DOTFILES_DEBUG_MODE}" == "true" ]] && echo -e "${ERR_BLUE}🐛 ${message}${ERR_NC}" >&2 ;;
    esac
}

# Enhanced error handlers
error() { log_error "ERROR" "$1" "${BASH_LINENO[0]}" "${FUNCNAME[1]}" "${BASH_SOURCE[1]##*/}"; }
warn() { log_error "WARN" "$1" "${BASH_LINENO[0]}" "${FUNCNAME[1]}" "${BASH_SOURCE[1]##*/}"; }
info() { log_error "INFO" "$1" "${BASH_LINENO[0]}" "${FUNCNAME[1]}" "${BASH_SOURCE[1]##*/}"; }
debug() { log_error "DEBUG" "$1" "${BASH_LINENO[0]}" "${FUNCNAME[1]}" "${BASH_SOURCE[1]##*/}"; }

# Stack trace function
print_stack_trace() {
    local frame=1
    echo "Stack trace:" >&2
    while [[ ${BASH_SOURCE[frame]} ]]; do
        echo "  ${frame}: ${BASH_SOURCE[frame]}:${BASH_LINENO[frame-1]} in function '${FUNCNAME[frame]}'" >&2
        ((frame++))
    done
}

# Global error handler
global_error_handler() {
    local exit_code=$?
    local line_number=${1:-$LINENO}
    
    if [[ ${exit_code} -ne 0 ]]; then
        error "Script failed with exit code ${exit_code} at line ${line_number}"
        print_stack_trace
        
        # Try to provide helpful context
        if [[ -n "${BASH_COMMAND}" ]]; then
            error "Failed command: ${BASH_COMMAND}"
        fi
        
        # Cleanup on error
        cleanup_on_error
    fi
    
    exit ${exit_code}
}

# Cleanup function (override in your scripts)
cleanup_on_error() {
    debug "Running error cleanup..."
    
    # Remove temporary files
    if [[ -n "${TEMP_FILES:-}" ]]; then
        for temp_file in ${TEMP_FILES}; do
            [[ -f "${temp_file}" ]] && rm -f "${temp_file}" && debug "Removed temp file: ${temp_file}"
        done
    fi
    
    # Remove temporary directories
    if [[ -n "${TEMP_DIRS:-}" ]]; then
        for temp_dir in ${TEMP_DIRS}; do
            [[ -d "${temp_dir}" ]] && rm -rf "${temp_dir}" && debug "Removed temp dir: ${temp_dir}"
        done
    fi
    
    # Kill background processes
    if [[ -n "${BACKGROUND_PIDS:-}" ]]; then
        for pid in ${BACKGROUND_PIDS}; do
            if kill -0 "${pid}" 2>/dev/null; then
                kill "${pid}" && debug "Killed background process: ${pid}"
            fi
        done
    fi
}

# Temporary file management
create_temp_file() {
    local temp_file
    temp_file=$(mktemp)
    TEMP_FILES="${TEMP_FILES:-} ${temp_file}"
    echo "${temp_file}"
}

create_temp_dir() {
    local temp_dir
    temp_dir=$(mktemp -d)
    TEMP_DIRS="${TEMP_DIRS:-} ${temp_dir}"
    echo "${temp_dir}"
}

# Safe command execution with retry
safe_execute() {
    local max_attempts="${1:-3}"
    local delay="${2:-1}"
    local command="${3}"
    shift 3
    
    local attempt=1
    while [[ ${attempt} -le ${max_attempts} ]]; do
        debug "Executing (attempt ${attempt}/${max_attempts}): ${command} $*"
        
        if ${command} "$@"; then
            debug "Command succeeded on attempt ${attempt}"
            return 0
        else
            local exit_code=$?
            warn "Command failed on attempt ${attempt} with exit code ${exit_code}: ${command} $*"
            
            if [[ ${attempt} -lt ${max_attempts} ]]; then
                debug "Retrying in ${delay} seconds..."
                sleep "${delay}"
                ((attempt++))
            else
                error "Command failed after ${max_attempts} attempts: ${command} $*"
                return ${exit_code}
            fi
        fi
    done
}

# Network operation with timeout
safe_curl() {
    local url="$1"
    local output="${2:--}"  # Default to stdout
    local timeout="${3:-30}"
    local max_retries="${4:-3}"
    
    debug "Downloading: ${url}"
    
    safe_execute "${max_retries}" 2 curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --max-time "${timeout}" \
        --output "${output}" \
        "${url}"
}

# Process management
track_background_process() {
    local pid="$1"
    BACKGROUND_PIDS="${BACKGROUND_PIDS:-} ${pid}"
    debug "Tracking background process: ${pid}"
}

wait_for_process() {
    local pid="$1"
    local timeout="${2:-30}"
    local count=0
    
    while [[ ${count} -lt ${timeout} ]] && kill -0 "${pid}" 2>/dev/null; do
        sleep 1
        ((count++))
    done
    
    if kill -0 "${pid}" 2>/dev/null; then
        warn "Process ${pid} still running after ${timeout} seconds"
        return 1
    else
        debug "Process ${pid} completed"
        return 0
    fi
}

# System requirements checking
check_requirement() {
    local requirement="$1"
    local error_message="${2:-Missing requirement: ${requirement}}"
    
    case "${requirement}" in
        "command:"*)
            local command="${requirement#command:}"
            if ! command -v "${command}" >/dev/null 2>&1; then
                error "${error_message}"
                return 1
            fi
            ;;
        "file:"*)
            local file="${requirement#file:}"
            if [[ ! -f "${file}" ]]; then
                error "${error_message}"
                return 1
            fi
            ;;
        "dir:"*)
            local dir="${requirement#dir:}"
            if [[ ! -d "${dir}" ]]; then
                error "${error_message}"
                return 1
            fi
            ;;
        "env:"*)
            local var="${requirement#env:}"
            if [[ -z "${!var:-}" ]]; then
                error "${error_message}"
                return 1
            fi
            ;;
        *)
            error "Unknown requirement type: ${requirement}"
            return 1
            ;;
    esac
    
    debug "Requirement satisfied: ${requirement}"
    return 0
}

# Validation functions
validate_not_empty() {
    local value="$1"
    local name="${2:-value}"
    
    if [[ -z "${value}" ]]; then
        error "${name} cannot be empty"
        return 1
    fi
    
    return 0
}

validate_file_readable() {
    local file="$1"
    
    if [[ ! -f "${file}" ]]; then
        error "File does not exist: ${file}"
        return 1
    fi
    
    if [[ ! -r "${file}" ]]; then
        error "File is not readable: ${file}"
        return 1
    fi
    
    return 0
}

validate_dir_writable() {
    local dir="$1"
    
    if [[ ! -d "${dir}" ]]; then
        error "Directory does not exist: ${dir}"
        return 1
    fi
    
    if [[ ! -w "${dir}" ]]; then
        error "Directory is not writable: ${dir}"
        return 1
    fi
    
    return 0
}

# Progress indication
show_progress() {
    local current="$1"
    local total="$2"
    local operation="${3:-Processing}"
    
    local percentage=$((current * 100 / total))
    local bar_length=40
    local filled_length=$((percentage * bar_length / 100))
    
    local bar=""
    for ((i=0; i<filled_length; i++)); do
        bar+="█"
    done
    for ((i=filled_length; i<bar_length; i++)); do
        bar+="░"
    done
    
    printf "\r%s [%s] %d%% (%d/%d)" "${operation}" "${bar}" "${percentage}" "${current}" "${total}"
    
    if [[ ${current} -eq ${total} ]]; then
        echo  # New line when complete
    fi
}

# Initialize error handling
init_error_handling() {
    # Set strict mode if enabled
    if [[ "${DOTFILES_STRICT_MODE}" == "true" ]]; then
        set -euo pipefail
    fi
    
    # Set up trap for errors
    trap 'global_error_handler $LINENO' ERR
    
    # Set up trap for script exit
    trap 'cleanup_on_error' EXIT
    
    info "Error handling initialized (strict=${DOTFILES_STRICT_MODE}, debug=${DOTFILES_DEBUG_MODE})"
}

# Recovery functions
attempt_recovery() {
    local recovery_action="$1"
    local recovery_message="${2:-Attempting recovery}"
    
    info "${recovery_message}"
    
    case "${recovery_action}" in
        "clean_temp")
            cleanup_on_error
            ;;
        "reset_permissions")
            find "${HOME}/.local" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
            ;;
        "rebuild_cache")
            [[ -d "${HOME}/.cache/zsh" ]] && rm -rf "${HOME}/.cache/zsh"
            mkdir -p "${HOME}/.cache/zsh"
            ;;
        *)
            warn "Unknown recovery action: ${recovery_action}"
            return 1
            ;;
    esac
    
    info "Recovery action completed: ${recovery_action}"
}

# Show error summary
show_error_summary() {
    if [[ -f "${DOTFILES_ERROR_LOG}" ]]; then
        local error_count
        error_count=$(grep -c "\[ERROR\]" "${DOTFILES_ERROR_LOG}" 2>/dev/null || echo "0")
        local warn_count
        warn_count=$(grep -c "\[WARN\]" "${DOTFILES_ERROR_LOG}" 2>/dev/null || echo "0")
        
        if [[ ${error_count} -gt 0 ]] || [[ ${warn_count} -gt 0 ]]; then
            echo
            echo "Error Summary:"
            echo "  Errors: ${error_count}"
            echo "  Warnings: ${warn_count}"
            echo "  Log file: ${DOTFILES_ERROR_LOG}"
            
            if [[ ${error_count} -gt 0 ]]; then
                echo
                echo "Recent errors:"
                tail -n 5 "${DOTFILES_ERROR_LOG}" | grep "\[ERROR\]" || true
            fi
        fi
    fi
}

# Export functions for use in other scripts
export -f error warn info debug
export -f safe_execute safe_curl
export -f check_requirement validate_not_empty validate_file_readable validate_dir_writable
export -f create_temp_file create_temp_dir
export -f show_progress attempt_recovery show_error_summary