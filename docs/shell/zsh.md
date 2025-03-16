# Zsh Configuration

A modular and well-organized Zsh configuration that provides a powerful and efficient command-line environment.

## Directory Structure

```
.config/zsh/
├── .zshenv          # Environment variables, always sourced first
├── .zprofile        # Login shell settings
├── .zshrc           # Interactive shell configuration
├── aliases.zsh      # Command aliases
├── exports.zsh      # Environment exports
├── path.zsh         # PATH modifications
├── tools.zsh        # Development tools configuration
├── local.zsh        # Local machine-specific settings
├── functions/       # Custom Zsh functions
├── completions/     # Custom completion definitions
├── plugins/         # Custom plugins
└── ohmyzsh/         # Oh My Zsh installation
```

## Core Configuration Files

### .zshenv

The first file sourced by Zsh, containing essential environment variables that should be available to all shells:
- Sets XDG base directories
- Configures Zsh history settings
- Sets core environment variables
- Available to both interactive and non-interactive shells

### .zprofile

Login shell configuration, sourced only for login shells:
- Sets up shell session management
- Configures login-specific environment variables
- Handles machine-specific login tasks

### .zshrc

Main configuration file for interactive shells:
- Sources modular configuration files
- Sets up Oh My Zsh
- Configures plugins and themes
- Sets shell options and key bindings
- Initializes completions

## Modular Components

### aliases.zsh

Common command aliases and shortcuts:
- Git aliases
- Directory navigation
- System commands
- Utility functions

### exports.zsh

Environment variable exports:
- Editor preferences
- Language settings
- Tool-specific configurations
- System preferences

### path.zsh

PATH environment management:
- User binaries
- System paths
- Tool-specific paths
- Custom script directories

### tools.zsh

Development tool configurations:
- Language version managers
- Build tools
- Development environments
- SDK configurations

### local.zsh

Machine-specific configurations:
- Local aliases
- Custom paths
- Machine-specific settings
- Private configurations

## Custom Components

### functions/

Custom Zsh functions directory:
- Utility functions
- Custom commands
- Shell helpers
- Task automation scripts

### completions/

Custom completion definitions:
- Tool-specific completions
- Command completions
- Custom completions

### plugins/

Custom plugin directory:
- Local plugins
- Custom extensions
- Specific functionality

## Integration

### Oh My Zsh

Integrated Oh My Zsh framework:
- Theme support
- Plugin management
- Completion system
- Framework utilities

## Features

1. Shell Experience:
   - Command history
   - Tab completion
   - Directory navigation
   - Command correction

2. Development Tools:
   - Language version management
   - Build tool integration
   - Development environments
   - SDK configurations

3. Customization:
   - Custom functions
   - Aliases
   - Key bindings
   - Machine-specific settings

4. Performance:
   - Lazy loading
   - Modular structure
   - Optimized sourcing
   - Efficient completions

## Tips

1. Use `local.zsh` for machine-specific settings
2. Add custom functions to the functions directory
3. Keep sensitive information in local.zsh
4. Use modular files for organization
5. Leverage Oh My Zsh plugins when available 