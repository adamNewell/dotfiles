# ~/.dotfiles

My personal dotfiles for macOS, managed with GNU Stow.

## Overview

This repository contains my personal dotfiles, with a focus on a well-organized and modular Zsh configuration. The setup is designed to be maintainable, performant, and secure.

## Structure

The Zsh configuration is organized into modular files under `.config/zsh/`:

```
.config/zsh/
├── .zshrc              # Main Zsh configuration
├── .zshenv             # Environment variables (loaded first)
├── .zprofile          # Login shell settings
├── path.zsh           # PATH configuration
├── exports.zsh        # Environment exports
├── tools.zsh          # Development tool configurations
├── aliases.zsh        # Custom aliases
├── functions.zsh      # Custom functions
├── extra.zsh          # Additional configurations
└── local.zsh          # Machine-specific settings (optional)
```

### Configuration Loading Order

1. `.zshenv` - Sets up essential environment variables and XDG paths
2. `.zprofile` - Configures login shell settings
3. `.zshrc` - Main configuration file that sources other modules in this order:
   - `path.zsh` - PATH configuration
   - `exports.zsh` - Environment variables
   - `tools.zsh` - Development tool configurations (Node.js, Python, Rust, Go)
   - `aliases.zsh` - Custom aliases
   - `functions.zsh` - Custom functions
   - `extra.zsh` - Additional configurations
   - `local.zsh` - Machine-specific settings

## Features

- **Oh My Zsh Integration**: Uses Oh My Zsh as the base framework with carefully selected plugins
- **Development Tools**: Organized configuration for:
  - Node.js/nvm
  - Python/pyenv
  - Rust/Cargo
  - Go
- **Performance Optimizations**:
  - Efficient plugin loading
  - Cached Homebrew prefix
  - Daily completion regeneration
- **Security Features**:
  - Secure umask settings
  - SSH agent management
  - Auto-logout after inactivity
- **Modern Shell Experience**:
  - Syntax highlighting
  - Auto-suggestions
  - History substring search
  - Fuzzy finding (FZF)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/adamnewell/dotfiles.git ~/.dotfiles
```

2. Run the installation script:
```bash
cd ~/.dotfiles
./install.zsh
```

## Customization

- Machine-specific configurations can be added to `local.zsh`
- Additional aliases can be added to `aliases.zsh`
- New development tool configurations should go in `tools.zsh`

## Dependencies

- Zsh
- Git
- GNU Stow
- Oh My Zsh
- Homebrew (for macOS)

## License

MIT
