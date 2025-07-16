# Adam Newell's Dotfiles

Modern, cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/), featuring automated setup, elegant package management, and intelligent shell configuration.

## 🚀 Quick Start

### One-Command Installation

```bash
# Complete environment setup (recommended)
curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash

# Minimal installation (essential tools only)
curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash -s -- --minimal

# Configuration only (skip packages)
curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash -s -- --skip-packages
```

### Alternative Installation

```bash
# Install chezmoi and apply dotfiles in one command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply adamNewell/dotfiles
```

### Existing Setup

```bash
# Update dotfiles from repository
chezmoi update

# Apply any pending changes
chezmoi apply
```

## ✨ Features

- **🏠 chezmoi Management**: Intelligent dotfile management with templating and cross-platform support
- **📦 Smart Package Management**: Cross-platform package installation with platform detection
- **⚡ Fast Shell Setup**: Optimized Zsh configuration with Sheldon plugin manager
- **🎨 Elegant macOS Defaults**: YAML-driven macOS system preferences configuration
- **🔧 XDG Compliant**: Modern file organization following XDG Base Directory specification
- **🌍 Cross-Platform**: Supports macOS, Linux, and Windows with intelligent platform detection

## 📁 Repository Structure

```
.dotfiles/
├── .local/share/chezmoi/           # chezmoi source directory
│   ├── dot_config/                 # ~/.config configurations
│   │   ├── git/                    # Git configuration with templates
│   │   ├── kitty/                  # Kitty terminal emulator
│   │   ├── nvim/                   # Neovim editor configuration
│   │   ├── sheldon/                # Sheldon Zsh plugin manager
│   │   ├── tmux/                   # tmux terminal multiplexer
│   │   └── zsh/                    # Organized Zsh configuration
│   │       ├── 01-environment.zsh  # Environment variables
│   │       ├── 02-path.zsh         # PATH configuration
│   │       ├── 03-plugins.zsh      # Plugin loading
│   │       ├── 10-completions.zsh  # Shell completions
│   │       ├── 20-tools/           # Tool-specific configs
│   │       └── 30-functions/       # Custom functions
│   ├── packages/                   # Package management
│   │   ├── package-definitions.yaml# Cross-platform package definitions
│   │   └── Brewfile.tmpl          # Templated Homebrew packages
│   ├── macos-defaults.yaml         # macOS system preferences
│   ├── run_once_*.sh.tmpl          # Automated setup scripts
│   ├── run_onchange_*.sh.tmpl      # Change-triggered scripts
│   └── .chezmoiexternal.yaml       # Direct binary downloads
├── .config/chezmoi/                # chezmoi configuration
└── docs/                           # Documentation
```

## 🛠️ Automated Setup Process

The dotfiles automatically handle complete machine setup through chezmoi's run scripts:

1. **`run_once_01-install-mise.sh.tmpl`** - Universal version manager for programming languages
2. **`run_once_02-install-platform-packages.sh.tmpl`** - Platform-specific package installation
3. **`run_once_03-install-universal-tools.sh.tmpl`** - Cross-platform CLI tools via cargo/npm/go
4. **`run_onchange_04-setup-shell-tools.sh.tmpl`** - Shell tool configuration and plugin setup
5. **`run_once_05-setup-macos-defaults.py.tmpl`** - Elegant macOS system preference configuration
6. **`run_once_99-validate-setup.sh.tmpl`** - Final validation and system check

## 📦 Package Management

### Cross-Platform Philosophy

The dotfiles use a hybrid package management approach for optimal tool availability:

- **mise/asdf**: Version management for programming languages (Node.js, Python, Go, Rust)
- **Cargo**: Rust-based CLI tools (ripgrep, fd, bat, eza, zoxide, sheldon)
- **Platform-specific**: Homebrew (macOS), apt/dnf/pacman (Linux), winget/scoop (Windows)
- **Direct downloads**: chezmoi externals for tools not available via package managers

### Package Definitions

All packages are defined in `packages/package-definitions.yaml` using a structured format:

```yaml
cli_tools:
  ripgrep:
    cargo: "ripgrep"
    brew: "ripgrep"
    apt: "ripgrep"
    description: "Fast grep replacement"
```

### Platform Detection

Templates automatically detect your platform and install appropriate packages:

```bash
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific packages
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific packages
{{- end }}
```

## ⚡ Shell Configuration

### Organized Loading Order

Zsh configuration uses numbered prefixes for predictable, optimized loading:

- **01-03**: Foundation layer (environment, PATH, plugins)
- **10-13**: Shell initialization (completions, history, options, keybindings)
- **20-29**: Tool configurations (language-specific settings)
- **30-39**: User interface (functions, aliases)
- **90+**: Local machine overrides

### Plugin Management

Uses [Sheldon](https://github.com/rossmacarthur/sheldon) for fast, reliable Zsh plugin management:

```toml
[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"

[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"
```

## 🍎 macOS System Preferences

Elegant system configuration using Python and YAML:

```yaml
# macos-defaults.yaml
finder:
  show_hidden_files: true
  show_all_extensions: true
  default_view: "column"

dock:
  icon_size: 36
  minimize_effect: "scale"
  hide_recent_apps: true
```

The Python script automatically maps YAML configuration to macOS defaults commands with proper type conversion and error handling.

## 🔧 Maintenance & Usage

### Common Operations

```bash
# Update dotfiles from repository
chezmoi update

# See what would change before applying
chezmoi diff

# Edit a configuration file
chezmoi edit ~/.config/zsh/01-environment.zsh

# Add a new file to management
chezmoi add ~/.config/newapp/config.yaml

# Re-run setup scripts
chezmoi apply --force

# Check system validation
~/.local/share/run_once_99-validate-setup.sh
```

### Package Management

```bash
# Update programming language versions
mise upgrade

# Update platform packages
brew upgrade                    # macOS
sudo apt upgrade               # Ubuntu/Debian
sudo dnf upgrade               # Fedora

# Update CLI tools
cargo install-update -a       # Rust tools
npm update -g                  # Node.js tools
```

### Shell Plugin Management

```bash
# Update plugin definitions
chezmoi edit ~/.config/sheldon/plugins.toml

# Rebuild plugin cache
sheldon lock

# Source updated configuration
exec zsh
```

## 🌍 Cross-Platform Support

### Supported Platforms

- **macOS**: Full support with Homebrew, system preferences, and app installation
- **Linux**: Support for major distributions (Ubuntu, Fedora, Arch) with automatic package manager detection
- **Windows**: Basic support via winget/scoop with PowerShell compatibility

### Platform-Specific Features

- **macOS**: System preferences, Homebrew casks, Mac App Store integration
- **Linux**: Distribution detection, package manager selection, XDG compliance
- **Windows**: Package installation via winget/scoop, PowerShell configuration

## 📚 Documentation

For detailed information about specific components:

- [Package Management](docs/PACKAGE_MANAGEMENT.md) - Cross-platform package installation
- [Shell Configuration](docs/SHELL_CONFIGURATION.md) - Zsh setup and organization
- [chezmoi Usage](docs/CHEZMOI_USAGE.md) - Dotfile management with chezmoi
- [macOS Setup](docs/MACOS_SETUP.md) - System preference configuration

## 🤝 Contributing

This is a personal dotfiles repository, but you're welcome to:

- Fork and adapt for your own use
- Submit issues for bugs or suggestions
- Contribute improvements via pull requests

## 📄 License

MIT License - feel free to use and modify as needed.

---

*These dotfiles are designed for efficiency, elegance, and cross-platform compatibility. They represent a modern approach to dotfile management using industry-standard tools and best practices.*