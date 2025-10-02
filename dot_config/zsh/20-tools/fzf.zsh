# FZF command-specific configuration
# Location: $XDG_CONFIG_HOME/fzf/fzf.zsh

# Set config file path for default options
export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/config"

# Default command (use fd for better performance and respect .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# CTRL-T command (file selector)
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --preview 'bat --style=numbers --color=always --line-range :500 {}'
  --bind 'ctrl-v:execute(nvim {})+abort'
  --header 'Press CTRL-V to edit in nvim'"

# ALT-C command (directory selector)
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --color=always {} | head -200'
  --header 'Press ENTER to cd into directory'"

# CTRL-R command (history search)
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:hidden:wrap
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
