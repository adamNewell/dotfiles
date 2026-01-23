#!/usr/bin/env bash
# Check installation status of all dotfiles tools
# Outputs a table showing each tool and whether it's installed

set -e
set -o pipefail

# Colors (using ANSI-C quoting for proper escape interpretation)
readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly YELLOW=$'\033[1;33m'
readonly BLUE=$'\033[0;34m'
readonly CYAN=$'\033[0;36m'
readonly BOLD=$'\033[1m'
readonly DIM=$'\033[2m'
readonly NC=$'\033[0m'

# Symbols
readonly CHECK="${GREEN}✓${NC}"
readonly CROSS="${RED}✗${NC}"
readonly WARN="${YELLOW}?${NC}"

# Tool definitions with command name and category
# Format: "display_name:command:category"
TOOLS=(
    # Essential system packages
    "gcc:gcc:essential"
    "g++:g++:essential"
    "curl:curl:essential"
    "wget:wget:essential"
    "git:git:essential"
    "zsh:zsh:essential"
    "tmux:tmux:essential"
    "neovim:nvim:essential"
    "tree:tree:essential"
    "unzip:unzip:essential"

    # CLI tools
    "eza:eza:cli"
    "fd:fd:cli"
    "ripgrep:rg:cli"
    "bat:bat:cli"
    "zoxide:zoxide:cli"
    "git-delta:delta:cli"
    "jq:jq:cli"
    "yq:yq:cli"
    "fzf:fzf:cli"
    "lazygit:lazygit:cli"
    "sheldon:sheldon:cli"
    "tldr:tldr:cli"

    # Version managers / Language tools
    "mise:mise:lang"
    "node:node:lang"
    "python:python3:lang"
    "rust/cargo:cargo:lang"
    "go:go:lang"
)

# Get version for a command
get_version() {
    local cmd="$1"
    local version=""

    case "${cmd}" in
        gcc)      version=$(gcc --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) ;;
        g++)      version=$(g++ --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) ;;
        curl)     version=$(curl --version 2>/dev/null | head -n1 | awk '{print $2}') ;;
        wget)     version=$(wget --version 2>/dev/null | head -n1 | awk '{print $3}') ;;
        git)      version=$(git --version 2>/dev/null | awk '{print $3}') ;;
        zsh)      version=$(zsh --version 2>/dev/null | awk '{print $2}') ;;
        tmux)     version=$(tmux -V 2>/dev/null | awk '{print $2}') ;;
        nvim)     version=$(nvim --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+') ;;
        tree)     version=$(tree --version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+') ;;
        unzip)    version=$(unzip -v 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+') ;;
        eza)      version=$(eza --version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1) ;;
        fd)       version=$(fd --version 2>/dev/null | awk '{print $2}') ;;
        rg)       version=$(rg --version 2>/dev/null | head -n1 | awk '{print $2}') ;;
        bat)      version=$(bat --version 2>/dev/null | awk '{print $2}') ;;
        zoxide)   version=$(zoxide --version 2>/dev/null | awk '{print $2}') ;;
        delta)    version=$(delta --version 2>/dev/null | awk '{print $2}') ;;
        jq)       version=$(jq --version 2>/dev/null | sed 's/jq-//') ;;
        yq)       version=$(yq --version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+') ;;
        fzf)      version=$(fzf --version 2>/dev/null | awk '{print $1}') ;;
        lazygit)  version=$(lazygit --version 2>/dev/null | grep -oE 'version=[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d= -f2) ;;
        sheldon)  version=$(sheldon --version 2>/dev/null | head -n1 | awk '{print $2}') ;;
        tldr)     version=$(tldr --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') ;;
        mise)     version=$(mise --version 2>/dev/null | awk '{print $1}') ;;
        node)     version=$(node --version 2>/dev/null) ;;
        python3)  version=$(python3 --version 2>/dev/null | awk '{print $2}') ;;
        cargo)    version=$(cargo --version 2>/dev/null | awk '{print $2}') ;;
        go)       version=$(go version 2>/dev/null | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | sed 's/go//') ;;
    esac

    echo "${version:-unknown}"
}

# Print table header
print_header() {
    local width=$1
    printf "\n${BOLD}%-20s │ %-7s │ %-13s │ %s${NC}\n" "Tool" "Status" "Version" "Category"
    printf "%.0s─" $(seq 1 "$width")
    printf "\n"
}

# Print table row
print_row() {
    local name="$1"
    local status="$2"
    local version="$3"
    local category="$4"

    local status_display
    if [[ "$status" == "installed" ]]; then
        status_display="${CHECK} found"
    else
        status_display="${CROSS} missing"
    fi

    local version_display
    if [[ "$status" == "installed" && -n "$version" && "$version" != "unknown" ]]; then
        version_display="${CYAN}${version}${NC}"
    else
        version_display="${DIM}-${NC}"
    fi

    local category_display
    case "$category" in
        essential) category_display="${BLUE}essential${NC}" ;;
        cli)       category_display="${GREEN}cli${NC}" ;;
        lang)      category_display="${YELLOW}lang${NC}" ;;
        *)         category_display="$category" ;;
    esac

    printf "%-20s │ %-17s │ %-24s │ %s\n" "$name" "$status_display" "$version_display" "$category_display"
}

# Print summary
print_summary() {
    local installed=$1
    local missing=$2
    local total=$((installed + missing))

    printf "\n${BOLD}Summary:${NC}\n"
    printf "  ${GREEN}Installed:${NC} %d/%d\n" "$installed" "$total"
    printf "  ${RED}Missing:${NC}   %d/%d\n" "$missing" "$total"

    if [[ $missing -gt 0 ]]; then
        printf "\n${YELLOW}Missing tools can be installed by running chezmoi apply${NC}\n"
    fi
}

# Main
main() {
    local filter="${1:-all}"
    local installed_count=0
    local missing_count=0
    local table_width=70

    echo -e "\n${BOLD}${BLUE}Dotfiles Tool Status${NC}"
    echo -e "${DIM}Checking installation status of configured tools...${NC}"

    print_header "$table_width"

    for tool_entry in "${TOOLS[@]}"; do
        IFS=':' read -r name cmd category <<< "$tool_entry"

        # Apply filter
        if [[ "$filter" != "all" && "$category" != "$filter" ]]; then
            continue
        fi

        if command -v "$cmd" >/dev/null 2>&1; then
            version=$(get_version "$cmd")
            print_row "$name" "installed" "$version" "$category"
            ((installed_count++)) || true
        else
            print_row "$name" "missing" "" "$category"
            ((missing_count++)) || true
        fi
    done

    printf "%.0s─" $(seq 1 "$table_width")
    printf "\n"

    print_summary "$installed_count" "$missing_count"
}

# Help
show_help() {
    cat << 'EOF'
Check Dotfiles Tools

Usage: check-tools.sh [category]

Categories:
  all        Show all tools (default)
  essential  Show only essential system packages
  cli        Show only CLI tools
  lang       Show only language/version manager tools

Examples:
  check-tools.sh           # Show all tools
  check-tools.sh cli       # Show only CLI tools
  check-tools.sh essential # Show only essential packages
EOF
}

case "${1:-}" in
    -h|--help|help)
        show_help
        ;;
    *)
        main "${1:-all}"
        ;;
esac
