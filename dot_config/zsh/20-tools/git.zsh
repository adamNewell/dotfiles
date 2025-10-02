# =============================================================================
#                               Git Configuration
# =============================================================================

# Git environment
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"

# Initialize SSH agent for git operations (if not already running)
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval $(ssh-agent -s -t 3600) > /dev/null
    # Add SSH keys with expiration
    for key in ~/.ssh/*; do
        case "$key" in
            *.pub|*known_hosts*|*config*) continue ;;
            *)
                [[ -f "$key" ]] && ssh-add -t 3600 "$key" 2>/dev/null || true
                ;;
        esac
    done
fi
