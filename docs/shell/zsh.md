# Zsh Configuration

A modular and well-organized Zsh configuration that provides a powerful and efficient command-line environment.

## Directory Structure

```
.config/zsh/
├── .zprofile
├── .zshenv
├── .zshrc
├── 01-environment.zsh
├── 01-platform.zsh
├── 02-path.zsh
├── 03-plugins.zsh
├── 10-completions.zsh
├── 11-history.zsh
├── 12-options.zsh
├── 13-keybindings.zsh
├── 20-tools/
├── 30-functions/
├── 31-aliases.zsh
└── 90-local.zsh
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
- Sets up Sheldon for plugin management
- Configures plugins and themes
- Sets shell options and key bindings
- Initializes completions

## Modular Components

The Zsh configuration is broken down into a series of modular files, loaded in a specific order to ensure a predictable and maintainable environment.

### 01-environment.zsh

- **Purpose**: Sets up the core environment, including XDG base directories and other fundamental environment variables.

### 02-path.zsh

- **Purpose**: Manages the `$PATH` environment variable, adding directories for user binaries, tool-specific paths, and system paths.

### 03-plugins.zsh

- **Purpose**: Loads Zsh plugins using Sheldon, a fast and declarative plugin manager.

### 10-completions.zsh

- **Purpose**: Configures the shell's autocompletion system, including enabling and configuring `compinit`.

### 11-history.zsh

- **Purpose**: Sets up command history with sensible defaults, such as history size and file location.

### 12-options.zsh

- **Purpose**: Configures shell behavior and features using `setopt`.

### 13-keybindings.zsh

- **Purpose**: Sets up custom key bindings for navigation, editing, and other actions.

### 20-tools/

- **Purpose**: A directory for tool-specific configurations, such as for `git`, `fzf`, and various programming languages.

### 30-functions/

- **Purpose**: A directory for custom shell functions, organized by category.

### 31-aliases.zsh

- **Purpose**: Contains common command aliases and shortcuts.

### 90-local.zsh

- **Purpose**: For machine-specific configurations and private settings that are not version-controlled.

## Plugin Management with Sheldon

This configuration uses [Sheldon](https://sheldon.cli.rs/) for Zsh plugin management. Sheldon is a fast, declarative plugin manager that uses a TOML file for configuration.

- **Configuration**: `dot_config/sheldon/plugins.toml`
- **Usage**: `sheldon lock` to update the plugin cache.

## Features

- **Modular and Organized**: The configuration is split into logical files, making it easy to manage and customize.
- **Fast Startup**: By using Sheldon and a well-organized structure, the shell starts quickly.
- **XDG Compliant**: The configuration follows the XDG Base Directory Specification for a clean home directory.
- **Customizable**: Easily extendable with custom functions, aliases, and tool configurations.

## Tips

- Use `90-local.zsh` for machine-specific settings.
- Add custom functions to the `30-functions/` directory.
- Keep sensitive information in `90-local.zsh`.
- Use the modular files to keep your configuration organized.
