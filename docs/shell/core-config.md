# Core Zsh Configuration Files

Detailed documentation of the core Zsh configuration files and their purposes.

## .zshenv

> Source: `dot_zshenv`

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

3. Core Environment:
   - Path to Zsh configuration (`ZDOTDIR`)

## .zprofile

> Source: `dot_config/zsh/.zprofile`

Sourced only for login shells, handles login-specific initialization.

### Purpose
- Login shell configuration
- Session management
- Environment setup
- Login-specific tasks

## .zshrc

> Source: `dot_config/zsh/.zshrc`

Main configuration file for interactive shells.

### Purpose
- Interactive shell setup
- Sources the modular configuration files

### Key Configurations

.zshrc is responsible for sourcing all the other modular configuration files in the correct order.

## Tips

1. Keep `.zshenv` minimal for fast loading.
2. Use `.zprofile` for machine-specific login tasks.
3. Organize your configuration into the modular files for better maintenance.
