#!/bin/bash
# Integration tests for dotfiles setup process
# Tests the complete installation and configuration pipeline

set -e

# Test configuration
readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "${TEST_DIR}")"
readonly TEST_LOG="${TEST_DIR}/test-results.log"
readonly TEST_TEMP_DIR="${TEST_DIR}/temp"

# Colors for test output
readonly TEST_RED='\033[0;31m'
readonly TEST_GREEN='\033[0;32m'
readonly TEST_YELLOW='\033[1;33m'
readonly TEST_BLUE='\033[0;34m'
readonly TEST_NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result logging
log_test_result() {
    local test_name="$1"
    local status="$2"
    local message="${3:-}"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') [${status}] ${test_name} - ${message}" >> "${TEST_LOG}"
}

# Test assertion functions
assert_command_exists() {
    local command="$1"
    local test_name="test_command_${command}_exists"
    
    ((TESTS_RUN++))
    
    if command -v "${command}" >/dev/null 2>&1; then
        echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Command '${command}' exists"
        log_test_result "${test_name}" "PASS" "Command found: $(which "${command}")"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Command '${command}' not found"
        log_test_result "${test_name}" "FAIL" "Command not found"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="test_file_${file//\//_}_exists"
    
    ((TESTS_RUN++))
    
    if [[ -f "${file}" ]]; then
        echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: File '${file}' exists"
        log_test_result "${test_name}" "PASS" "File size: $(stat -f%z "${file}" 2>/dev/null || stat -c%s "${file}" 2>/dev/null || echo "unknown")"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: File '${file}' not found"
        log_test_result "${test_name}" "FAIL" "File missing"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_directory_exists() {
    local dir="$1"
    local test_name="test_directory_${dir//\//_}_exists"
    
    ((TESTS_RUN++))
    
    if [[ -d "${dir}" ]]; then
        echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Directory '${dir}' exists"
        log_test_result "${test_name}" "PASS" "Directory exists"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Directory '${dir}' not found"
        log_test_result "${test_name}" "FAIL" "Directory missing"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_script_runs() {
    local script="$1"
    local expected_exit_code="${2:-0}"
    local test_name="test_script_${script//\//_}_runs"
    
    ((TESTS_RUN++))
    
    local actual_exit_code=0
    local output
    
    if output=$(bash "${script}" 2>&1); then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi
    
    if [[ ${actual_exit_code} -eq ${expected_exit_code} ]]; then
        echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Script '${script}' runs successfully"
        log_test_result "${test_name}" "PASS" "Exit code: ${actual_exit_code}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Script '${script}' failed (exit code: ${actual_exit_code}, expected: ${expected_exit_code})"
        echo "Output: ${output}"
        log_test_result "${test_name}" "FAIL" "Exit code: ${actual_exit_code}, expected: ${expected_exit_code}"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_env_var_set() {
    local var_name="$1"
    local test_name="test_env_${var_name}_set"
    
    ((TESTS_RUN++))
    
    if [[ -n "${!var_name:-}" ]]; then
        echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Environment variable '${var_name}' is set"
        log_test_result "${test_name}" "PASS" "Value: ${!var_name}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Environment variable '${var_name}' is not set"
        log_test_result "${test_name}" "FAIL" "Variable not set"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Platform detection tests
test_platform_detection() {
    echo -e "${TEST_BLUE}🧪 Testing platform detection...${TEST_NC}"
    
    # Source the platform detection script
    if [[ -f "${REPO_ROOT}/.local/share/chezmoi/dot_config/zsh/01-platform.zsh" ]]; then
        source "${REPO_ROOT}/.local/share/chezmoi/dot_config/zsh/01-platform.zsh"
        
        assert_env_var_set "DOTFILES_OS"
        assert_env_var_set "DOTFILES_PLATFORM" 
        assert_env_var_set "DOTFILES_PACKAGE_MANAGER"
        assert_env_var_set "DOTFILES_ARCH"
        
        # Test helper functions
        if declare -f is_macos >/dev/null 2>&1; then
            echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Platform helper functions loaded"
        else
            echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Platform helper functions not loaded"
            ((TESTS_FAILED++))
        fi
        
    else
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Platform detection script not found"
        ((TESTS_FAILED++))
    fi
}

# File structure tests
test_file_structure() {
    echo -e "${TEST_BLUE}🧪 Testing file structure...${TEST_NC}"
    
    # Essential files
    assert_file_exists "${REPO_ROOT}/README.md"
    assert_file_exists "${REPO_ROOT}/install.sh"
    assert_file_exists "${REPO_ROOT}/REFACTOR_PLAN.md"
    
    # Chezmoi configuration
    assert_directory_exists "${REPO_ROOT}/.local/share/chezmoi"
    assert_file_exists "${REPO_ROOT}/.local/share/chezmoi/.chezmoiignore"
    assert_file_exists "${REPO_ROOT}/.local/share/chezmoi/.chezmoiexternal.yaml"
    
    # Documentation
    assert_file_exists "${REPO_ROOT}/.local/share/chezmoi/ENCRYPTION.md"
    assert_file_exists "${REPO_ROOT}/.local/share/chezmoi/dot_config/zsh/README.md"
    
    # Scripts
    assert_file_exists "${REPO_ROOT}/.local/share/chezmoi/scripts/package-manager.sh"
    assert_file_exists "${REPO_ROOT}/.local/share/chezmoi/scripts/error-handler.sh"
    
    # Package definitions
    assert_file_exists "${REPO_ROOT}/.local/share/chezmoi/packages/simplified-packages.yaml"
}

# Script validation tests
test_script_validation() {
    echo -e "${TEST_BLUE}🧪 Testing script validation...${TEST_NC}"
    
    # Test shell syntax
    find "${REPO_ROOT}" -name "*.sh" -type f | while read -r script; do
        if bash -n "${script}" 2>/dev/null; then
            echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Shell syntax valid for '${script}'"
        else
            echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Shell syntax invalid for '${script}'"
            ((TESTS_FAILED++))
        fi
    done
    
    # Test zsh syntax
    if command -v zsh >/dev/null 2>&1; then
        find "${REPO_ROOT}/.local/share/chezmoi" -name "*.zsh" -type f | while read -r script; do
            if zsh -n "${script}" 2>/dev/null; then
                echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Zsh syntax valid for '${script}'"
            else
                echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Zsh syntax invalid for '${script}'"
                ((TESTS_FAILED++))
            fi
        done
    fi
}

# Package management tests
test_package_management() {
    echo -e "${TEST_BLUE}🧪 Testing package management...${TEST_NC}"
    
    # Test package manager script
    local pm_script="${REPO_ROOT}/.local/share/chezmoi/scripts/package-manager.sh"
    if [[ -x "${pm_script}" ]]; then
        # Check bash version first
        if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
            # Test help command
            if "${pm_script}" help >/dev/null 2>&1; then
                echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Package manager help works"
                ((TESTS_PASSED++))
            else
                echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Package manager help failed"
                ((TESTS_FAILED++))
            fi
            
            # Test dependency resolution
            if "${pm_script}" dependencies git >/dev/null 2>&1; then
                echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Dependency resolution works"
                ((TESTS_PASSED++))
            else
                echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Dependency resolution failed"
                ((TESTS_FAILED++))
            fi
        else
            echo -e "${TEST_YELLOW}⚠️  SKIP${TEST_NC}: Package manager requires bash 4.0+ (current: ${BASH_VERSION})"
            ((TESTS_RUN += 2))  # Account for skipped tests
        fi
    else
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Package manager script not executable"
        ((TESTS_FAILED++))
    fi
}

# Security tests
test_security() {
    echo -e "${TEST_BLUE}🧪 Testing security...${TEST_NC}"
    
    # Check for hardcoded secrets (more specific patterns)
    if grep -r -E "(password|secret|token)\s*=\s*['\"][^'\"]{8,}['\"]" "${REPO_ROOT}" --exclude-dir=.git --exclude="*.log" --exclude-dir=tests --exclude-dir=docs | grep -v -E "(example|test|TODO|template|\.chezmoiignore|macos-defaults)" | grep -q .; then
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Potential hardcoded secrets found"
        ((TESTS_FAILED++))
    else
        echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: No hardcoded secrets found"
        ((TESTS_PASSED++))
    fi
    
    # Check script permissions
    find "${REPO_ROOT}" -name "*.sh" -type f | while read -r script; do
        if [[ -x "${script}" ]]; then
            echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Script '${script}' is executable"
        else
            echo -e "${TEST_YELLOW}⚠️  WARN${TEST_NC}: Script '${script}' is not executable"
        fi
    done
    
    # Check for world-writable files
    if find "${REPO_ROOT}" -type f -perm -002 | grep -q .; then
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: World-writable files found"
        ((TESTS_FAILED++))
    else
        echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: No world-writable files found"
        ((TESTS_PASSED++))
    fi
}

# Error handling tests
test_error_handling() {
    echo -e "${TEST_BLUE}🧪 Testing error handling...${TEST_NC}"
    
    # Source error handler
    if [[ -f "${REPO_ROOT}/.local/share/chezmoi/scripts/error-handler.sh" ]]; then
        source "${REPO_ROOT}/.local/share/chezmoi/scripts/error-handler.sh"
        
        # Test error functions exist
        if declare -f error >/dev/null 2>&1; then
            echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Error handling functions loaded"
            ((TESTS_PASSED++))
        else
            echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Error handling functions not loaded"
            ((TESTS_FAILED++))
        fi
        
        # Test temp file creation
        local temp_file
        temp_file=$(create_temp_file)
        if [[ -f "${temp_file}" ]]; then
            echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Temporary file creation works"
            ((TESTS_PASSED++))
        else
            echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Temporary file creation failed"
            ((TESTS_FAILED++))
        fi
        
    else
        echo -e "${TEST_RED}❌ FAIL${TEST_NC}: Error handler script not found"
        ((TESTS_FAILED++))
    fi
}

# Performance tests
test_performance() {
    echo -e "${TEST_BLUE}🧪 Testing performance...${TEST_NC}"
    
    # Test zsh config loading time
    local start_time end_time duration
    start_time=$(date +%s%N)
    
    # Simulate loading zsh configs
    for config in "${REPO_ROOT}"/.local/share/chezmoi/dot_config/zsh/*.zsh; do
        if [[ -f "${config}" ]]; then
            bash -n "${config}" >/dev/null 2>&1
        fi
    done
    
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    if [[ ${duration} -lt 1000 ]]; then  # Less than 1 second
        echo -e "${TEST_GREEN}✅ PASS${TEST_NC}: Config loading time: ${duration}ms"
        ((TESTS_PASSED++))
    else
        echo -e "${TEST_YELLOW}⚠️  WARN${TEST_NC}: Config loading time: ${duration}ms (slow)"
    fi
}

# Cleanup test artifacts
cleanup_tests() {
    if [[ -d "${TEST_TEMP_DIR}" ]]; then
        rm -rf "${TEST_TEMP_DIR}"
    fi
}

# Main test runner
main() {
    echo -e "${TEST_BLUE}🚀 Starting dotfiles integration tests...${TEST_NC}"
    echo "Test log: ${TEST_LOG}"
    echo
    
    # Initialize test log
    mkdir -p "$(dirname "${TEST_LOG}")"
    echo "# Dotfiles Integration Test Results - $(date)" > "${TEST_LOG}"
    echo "# Repository: ${REPO_ROOT}" >> "${TEST_LOG}"
    echo "# Platform: $(uname -a)" >> "${TEST_LOG}"
    echo >> "${TEST_LOG}"
    
    # Create temp directory
    mkdir -p "${TEST_TEMP_DIR}"
    
    # Run test suites
    test_platform_detection
    echo
    test_file_structure
    echo
    test_script_validation
    echo
    test_package_management
    echo
    test_security
    echo
    test_error_handling
    echo
    test_performance
    echo
    
    # Test summary
    echo -e "${TEST_BLUE}📊 Test Summary:${TEST_NC}"
    echo "  Total tests: ${TESTS_RUN}"
    echo -e "  Passed: ${TEST_GREEN}${TESTS_PASSED}${TEST_NC}"
    echo -e "  Failed: ${TEST_RED}${TESTS_FAILED}${TEST_NC}"
    
    local success_rate=0
    if [[ ${TESTS_RUN} -gt 0 ]]; then
        success_rate=$((TESTS_PASSED * 100 / TESTS_RUN))
    fi
    echo "  Success rate: ${success_rate}%"
    
    # Log summary
    echo >> "${TEST_LOG}"
    echo "# Test Summary" >> "${TEST_LOG}"
    echo "Total tests: ${TESTS_RUN}" >> "${TEST_LOG}"
    echo "Passed: ${TESTS_PASSED}" >> "${TEST_LOG}"
    echo "Failed: ${TESTS_FAILED}" >> "${TEST_LOG}"
    echo "Success rate: ${success_rate}%" >> "${TEST_LOG}"
    
    # Cleanup
    cleanup_tests
    
    # Exit with error if any tests failed
    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        echo -e "${TEST_RED}❌ Some tests failed. Check the log for details.${TEST_NC}"
        exit 1
    else
        echo -e "${TEST_GREEN}✅ All tests passed!${TEST_NC}"
        exit 0
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi