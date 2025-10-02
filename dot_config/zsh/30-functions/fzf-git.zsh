# Async load fzf-git only if fzf is installed
if (( $+commands[fzf] )); then
    typeset fzf_git_url="https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh"
    typeset fzf_git_cache="${XDG_CACHE_HOME:-$HOME/.cache}/fzf-git.sh"

    # Create cache directory if it doesn't exist
    mkdir -p "${fzf_git_cache:h}"

    # Download in background and source when ready
    {
        if command -v curl >/dev/null 2>&1; then
            curl -sSL "$fzf_git_url" >| "$fzf_git_cache.new" 2>/dev/null
        elif command -v wget >/dev/null 2>&1; then
            wget -q -O "$fzf_git_cache.new" "$fzf_git_url" 2>/dev/null
        fi

        # Only replace cache if download was successful
        if [[ -f "$fzf_git_cache.new" && -s "$fzf_git_cache.new" ]]; then
            mv "$fzf_git_cache.new" "$fzf_git_cache"
            # Source the file in the background
            source "$fzf_git_cache"
        fi
    } &!

    # Source existing cache if available
    [[ -f "$fzf_git_cache" ]] && source "$fzf_git_cache"
fi
