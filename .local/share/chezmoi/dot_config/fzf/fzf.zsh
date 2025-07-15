# FZF configuration
# Location: $XDG_CONFIG_HOME/fzf/fzf.zsh

# Default command (use fd for better performance and respect .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Default options
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  --inline-info
  --preview-window=right:60%
  --bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort'
  --bind 'ctrl-e:execute(echo {} | xargs -o nvim)+abort'
  --color=bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374
  --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934
  --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934"

# CTRL-T command
export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="
  --preview 'bat --style=numbers --color=always --line-range :500 {}'
  --bind 'ctrl-v:execute(nvim {})+abort'"

# ALT-C command  
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --color=always {} | head -200'"

# CTRL-R command
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:hidden:wrap
  --bind 'ctrl-p:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"