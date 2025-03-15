# FZF related functions

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path () {
    fd --hidden --exclude git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir () {
    fd --type=d —-hidden --exclude .git . "$1"
}

fzf_comprun() {
    local command=$1
    shift

    case "$command" in
      cd)         fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
      export|unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
      ssh)        fzf --preview 'dig {}'            "$@" ;;
      *)          fzf --preview "--preview 'bat -n --color=always --line-range :500 {}'" "$@" ;;
    esac
} 