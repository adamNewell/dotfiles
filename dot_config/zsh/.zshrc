# =============================================================================
#                               Zsh Configuration
# =============================================================================
# Main zsh configuration file - organized for maintainability and performance

# =============================================================================
#                               Early Initialization
# =============================================================================

# Source environment variables first
[[ -f "$HOME/.config/.env" ]] && source "$HOME/.config/.env"

# Helper function for sourcing files
source_if_exists() { [[ -f "$1" && -r "$1" ]] && source "$1" }

# =============================================================================
#                               Modular Configuration Loading
# =============================================================================
# Load configurations in order of dependency:
# 1. Foundation layer - Environment, PATH, plugins
# 2. Initialization layer - Shell behavior, completions, history, keybindings  
# 3. Tools layer - Development tools and their configurations
# 4. Interface layer - Functions, aliases, and user customizations

# Foundation Layer (01-03)
for config_file in "$ZDOTDIR"/0[1-3]-*.zsh(N); do
    source_if_exists "$config_file"
done

# Initialization Layer (10-13)  
for config_file in "$ZDOTDIR"/1[0-3]-*.zsh(N); do
    source_if_exists "$config_file"
done

# Tools Layer (20-29)
for config_file in "$ZDOTDIR"/20-tools/*.zsh(N); do
    source_if_exists "$config_file"
done

# Interface Layer (30-39, 90+)
for config_file in "$ZDOTDIR"/3[0-9]-*.zsh(N) "$ZDOTDIR"/30-functions/*.zsh(N) "$ZDOTDIR"/9[0-9]-*.zsh(N); do
    source_if_exists "$config_file"
done

# =============================================================================
#                               Performance Optimizations
# =============================================================================

# Compile zcompdump if needed (background process)
{
    zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
    [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]] && \
        zcompile "$zcompdump" >/dev/null 2>&1
} &!