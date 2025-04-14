# Zsh Modular Components

Documentation for the modular Zsh configuration components that extend the core functionality.

## aliases.zsh

> Source: `.config/zsh/aliases.zsh`

Common command aliases and shortcuts for improved productivity.

### Categories

1. Git Aliases:
   ```zsh
   alias g='git'
   alias ga='git add'
   alias gc='git commit'
   alias gp='git push'
   ```

2. Directory Navigation:
   ```zsh
   alias ..='cd ..'
   alias ...='cd ../..'
   alias ll='ls -lah'
   alias l='ls -lh'
   ```

3. System Commands:
   ```zsh
   alias df='df -h'
   alias du='du -h'
   alias grep='grep --color=auto'
   ```

4. Development:
   ```zsh
   alias py='python'
   alias pip='pip3'
   alias node='node'
   ```

## exports.zsh

> Source: `.config/zsh/exports.zsh`

Environment variable exports for various tools and settings.

### Categories

1. Editor Settings:
   ```zsh
   export EDITOR='nvim'
   export VISUAL='nvim'
   export PAGER='less'
   ```

2. Language Settings:
   ```zsh
   export LANG='en_US.UTF-8'
   export LC_ALL='en_US.UTF-8'
   ```

3. Tool Configurations:
   ```zsh
   export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'
   export BAT_THEME='Dracula'
   ```

## path.zsh

> Source: `.config/zsh/path.zsh`

PATH environment management and modifications.

### Categories

1. User Binaries:
   ```zsh
   path=(
     $HOME/.local/bin
     $HOME/bin
     $path
   )
   ```

2. Tool-specific Paths:
   ```zsh
   path=(
     $CARGO_HOME/bin
     $GOPATH/bin
     $path
   )
   ```

3. System Paths:
   ```zsh
   path=(
     /usr/local/bin
     /usr/bin
     /bin
     $path
   )
   ```

## tools.zsh

> Source: `.config/zsh/tools.zsh`

Development tool configurations and initializations.

### Categories

1. Language Version Managers:
   ```zsh
   # Python - pyenv
   eval "$(pyenv init -)"
   
   # Node.js - nvm
   [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
   
   # Rust - rustup
   source "$CARGO_HOME/env"
   ```

2. Build Tools:
   ```zsh
   # Homebrew
   eval "$(/opt/homebrew/bin/brew shellenv)"
   
   # Make
   export MAKEFLAGS="-j$(nproc)"
   ```

## local.zsh

> Source: `.config/zsh/local.zsh`

Machine-specific configurations and private settings.

### Categories

1. Local Settings:
   ```zsh
   # Machine-specific aliases
   alias project='cd ~/Projects/current'
   
   # Local paths
   path=($HOME/Work/bin $path)
   ```

2. Private Configurations:
   ```zsh
   # API keys
   export API_KEY='xxx'
   
   # Private aliases
   alias work='cd ~/Work/private'
   ```

## Tips

1. Organization:
   - Group related aliases together
   - Comment sections clearly
   - Use descriptive names
   - Keep files focused

2. Maintenance:
   - Review aliases regularly
   - Update paths when needed
   - Clean up unused exports
   - Document changes

3. Performance:
   - Keep files lightweight
   - Use lazy loading when possible
   - Minimize dependencies
   - Profile load times

4. Security:
   - Keep sensitive data in local.zsh
   - Use environment variables
   - Avoid hardcoding credentials
   - Check file permissions 