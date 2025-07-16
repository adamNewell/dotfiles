# =============================================================================
#                           Platform Detection & Configuration
# =============================================================================
# This file sets up platform-specific variables and functions

# Platform detection
export DOTFILES_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
export DOTFILES_ARCH="$(uname -m)"

# Normalize architecture names
case "${DOTFILES_ARCH}" in
    x86_64|amd64) export DOTFILES_ARCH="amd64" ;;
    aarch64|arm64) export DOTFILES_ARCH="arm64" ;;
    armv7l) export DOTFILES_ARCH="arm" ;;
esac

# Platform-specific configuration
case "${DOTFILES_OS}" in
    "darwin")
        export DOTFILES_PLATFORM="macos"
        export DOTFILES_IS_MACOS=true
        export DOTFILES_IS_LINUX=false
        export DOTFILES_IS_WINDOWS=false
        
        # macOS-specific settings
        export BROWSER="open"
        export DOTFILES_PACKAGE_MANAGER="brew"
        
        # Detect macOS version
        export DOTFILES_MACOS_VERSION="$(sw_vers -productVersion)"
        
        # Check if Apple Silicon
        if [[ "${DOTFILES_ARCH}" == "arm64" ]]; then
            export DOTFILES_IS_APPLE_SILICON=true
        else
            export DOTFILES_IS_APPLE_SILICON=false
        fi
        ;;
    "linux")
        export DOTFILES_PLATFORM="linux"
        export DOTFILES_IS_MACOS=false
        export DOTFILES_IS_LINUX=true
        export DOTFILES_IS_WINDOWS=false
        export DOTFILES_IS_APPLE_SILICON=false
        
        # Detect Linux distribution
        if [[ -f "/etc/os-release" ]]; then
            source "/etc/os-release"
            export DOTFILES_LINUX_DISTRO="${ID:-unknown}"
            export DOTFILES_LINUX_VERSION="${VERSION_ID:-unknown}"
        else
            export DOTFILES_LINUX_DISTRO="unknown"
            export DOTFILES_LINUX_VERSION="unknown"
        fi
        
        # Detect package manager
        if command -v apt-get >/dev/null 2>&1; then
            export DOTFILES_PACKAGE_MANAGER="apt"
        elif command -v dnf >/dev/null 2>&1; then
            export DOTFILES_PACKAGE_MANAGER="dnf"
        elif command -v pacman >/dev/null 2>&1; then
            export DOTFILES_PACKAGE_MANAGER="pacman"
        elif command -v zypper >/dev/null 2>&1; then
            export DOTFILES_PACKAGE_MANAGER="zypper"
        else
            export DOTFILES_PACKAGE_MANAGER="unknown"
        fi
        
        # Linux-specific settings
        export BROWSER="${BROWSER:-xdg-open}"
        ;;
    "mingw"*|"msys"*|"cygwin"*)
        export DOTFILES_PLATFORM="windows"
        export DOTFILES_IS_MACOS=false
        export DOTFILES_IS_LINUX=false
        export DOTFILES_IS_WINDOWS=true
        export DOTFILES_IS_APPLE_SILICON=false
        
        # Windows-specific settings
        export BROWSER="${BROWSER:-cmd.exe /c start}"
        
        # Detect Windows package manager
        if command -v winget >/dev/null 2>&1; then
            export DOTFILES_PACKAGE_MANAGER="winget"
        elif command -v scoop >/dev/null 2>&1; then
            export DOTFILES_PACKAGE_MANAGER="scoop"
        else
            export DOTFILES_PACKAGE_MANAGER="unknown"
        fi
        ;;
    *)
        export DOTFILES_PLATFORM="unknown"
        export DOTFILES_IS_MACOS=false
        export DOTFILES_IS_LINUX=false
        export DOTFILES_IS_WINDOWS=false
        export DOTFILES_IS_APPLE_SILICON=false
        export DOTFILES_PACKAGE_MANAGER="unknown"
        ;;
esac

# Capability detection
export DOTFILES_HAS_BREW=false
export DOTFILES_HAS_MISE=false
export DOTFILES_HAS_DOCKER=false
export DOTFILES_HAS_SYSTEMD=false

command -v brew >/dev/null 2>&1 && export DOTFILES_HAS_BREW=true
command -v mise >/dev/null 2>&1 && export DOTFILES_HAS_MISE=true
command -v docker >/dev/null 2>&1 && export DOTFILES_HAS_DOCKER=true
[[ -d "/run/systemd/system" ]] && export DOTFILES_HAS_SYSTEMD=true

# Helper functions for platform detection
is_macos() { [[ "${DOTFILES_IS_MACOS}" == "true" ]]; }
is_linux() { [[ "${DOTFILES_IS_LINUX}" == "true" ]]; }
is_windows() { [[ "${DOTFILES_IS_WINDOWS}" == "true" ]]; }
is_apple_silicon() { [[ "${DOTFILES_IS_APPLE_SILICON}" == "true" ]]; }

has_brew() { [[ "${DOTFILES_HAS_BREW}" == "true" ]]; }
has_mise() { [[ "${DOTFILES_HAS_MISE}" == "true" ]]; }
has_docker() { [[ "${DOTFILES_HAS_DOCKER}" == "true" ]]; }
has_systemd() { [[ "${DOTFILES_HAS_SYSTEMD}" == "true" ]]; }

# Package manager helper
get_package_manager() {
    echo "${DOTFILES_PACKAGE_MANAGER}"
}

# Platform-specific paths
get_config_dir() {
    case "${DOTFILES_PLATFORM}" in
        "macos"|"linux") echo "${XDG_CONFIG_HOME:-$HOME/.config}" ;;
        "windows") echo "${APPDATA:-$HOME/AppData/Roaming}" ;;
        *) echo "$HOME/.config" ;;
    esac
}

get_data_dir() {
    case "${DOTFILES_PLATFORM}" in
        "macos"|"linux") echo "${XDG_DATA_HOME:-$HOME/.local/share}" ;;
        "windows") echo "${LOCALAPPDATA:-$HOME/AppData/Local}" ;;
        *) echo "$HOME/.local/share" ;;
    esac
}

get_cache_dir() {
    case "${DOTFILES_PLATFORM}" in
        "macos"|"linux") echo "${XDG_CACHE_HOME:-$HOME/.cache}" ;;
        "windows") echo "${TEMP:-$HOME/AppData/Local/Temp}" ;;
        *) echo "$HOME/.cache" ;;
    esac
}

# Tool path discovery
find_tool_path() {
    local tool="$1"
    local paths=()
    
    case "${tool}" in
        "brew")
            paths=(
                "/opt/homebrew/bin/brew"      # Apple Silicon
                "/usr/local/bin/brew"         # Intel Mac
                "/home/linuxbrew/.linuxbrew/bin/brew"  # Linux
            )
            ;;
        "nvm")
            paths=(
                "$HOME/.nvm/nvm.sh"
                "/opt/homebrew/opt/nvm/nvm.sh"
                "/usr/local/opt/nvm/nvm.sh"
                "/usr/share/nvm/nvm.sh"
                "/usr/local/share/nvm/nvm.sh"
            )
            ;;
        "fzf")
            paths=(
                "/opt/homebrew/share/fzf"     # macOS Homebrew
                "/usr/local/share/fzf"        # macOS Intel
                "/usr/share/fzf"              # Linux
                "$HOME/.fzf"                  # User install
            )
            ;;
    esac
    
    for path in "${paths[@]}"; do
        if [[ -e "${path}" ]]; then
            echo "${path}"
            return 0
        fi
    done
    
    return 1
}

# Debug output (only if DOTFILES_DEBUG is set)
if [[ -n "${DOTFILES_DEBUG}" ]]; then
    echo "Platform Detection Results:"
    echo "  OS: ${DOTFILES_OS}"
    echo "  Architecture: ${DOTFILES_ARCH}"
    echo "  Platform: ${DOTFILES_PLATFORM}"
    echo "  Package Manager: ${DOTFILES_PACKAGE_MANAGER}"
    echo "  Has Brew: ${DOTFILES_HAS_BREW}"
    echo "  Has Mise: ${DOTFILES_HAS_MISE}"
    echo "  Apple Silicon: ${DOTFILES_IS_APPLE_SILICON}"
fi