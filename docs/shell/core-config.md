# Core Zsh Configuration Files

Detailed documentation of the core Zsh configuration files and their purposes.

## .zshenv

> Source: `.config/zsh/.zshenv`

The first file sourced by Zsh for all shell types (login, interactive, script).

### Purpose
- Sets fundamental environment variables
- Configures core shell behavior
- Available to all shell types
- Minimal and fast-loading

### Key Configurations
1. XDG Base Directories:
   - `$XDG_CONFIG_HOME`
   - `$XDG_CACHE_HOME`
   - `$XDG_DATA_HOME`
   - `$XDG_STATE_HOME`

2. History Settings:
   - History file location
   - History size
   - History format
   - Save timestamps

3. Core Environment:
   - Shell options
   - Path to Zsh configuration
   - Essential variables

## .zprofile

> Source: `.config/zsh/.zprofile`

Sourced only for login shells, handles login-specific initialization.

### Purpose
- Login shell configuration
- Session management
- Environment setup
- Login-specific tasks

### Key Configurations
1. Shell Session:
   - Session directory
   - Session file
   - Session history

2. Login Environment:
   - User preferences
   - System settings
   - Login hooks

## .zshrc

> Source: `.config/zsh/.zshrc`

Main configuration file for interactive shells.

### Purpose
- Interactive shell setup
- Plugin management
- User interface
- Shell behavior

### Key Configurations
1. Oh My Zsh Setup:
   ```zsh
   # Oh My Zsh configuration
   ZSH_THEME="robbyrussell"
   plugins=(git docker kubectl)
   source $ZSH/oh-my-zsh.sh
   ```

2. Module Loading:
   ```zsh
   # Load custom modules
   for config in $ZDOTDIR/*.zsh; do
     source $config
   done
   ```

3. Shell Options:
   ```zsh
   # Shell behavior
   setopt AUTO_CD
   setopt EXTENDED_GLOB
   setopt NOMATCH
   setopt NOTIFY
   ```

4. Key Bindings:
   ```zsh
   # Key bindings
   bindkey -e  # Emacs key bindings
   bindkey '^[[A' history-substring-search-up
   bindkey '^[[B' history-substring-search-down
   ```

### Features
1. Interactive Features:
   - Command completion
   - Syntax highlighting
   - History search
   - Directory navigation

2. Plugin Management:
   - Oh My Zsh integration
   - Custom plugin loading
   - Plugin configuration

3. User Interface:
   - Theme settings
   - Prompt configuration
   - Terminal title
   - Color support

4. Shell Behavior:
   - Command correction
   - Directory handling
   - Job control
   - Input/output

## Tips

1. Keep .zshenv minimal for fast loading
2. Use .zprofile for machine-specific login tasks
3. Organize .zshrc with clear sections
4. Comment configurations for clarity
5. Use modular files for better maintenance 