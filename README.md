# Adam Newell's Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), featuring automated setup, cross-platform package management, and organized shell configuration.

## 🚀 Installation

### Complete Setup

```bash
# Full environment setup (recommended)
curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash

# Minimal installation (essential tools only)
curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash -s -- --minimal

# Configuration only (skip packages)
curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash -s -- --skip-packages
```

### Alternative Methods

```bash
# Direct chezmoi installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply adamNewell/dotfiles

# Update existing setup
chezmoi update
```

## ✨ Components

- **🏠 chezmoi Management**: Templated dotfile management with cross-platform support
- **📦 Package Management**: Platform-aware package installation (Homebrew, apt, dnf, winget/scoop)
- **⚡ Shell Configuration**: Organized Zsh setup with Sheldon plugin manager
- **🎨 macOS Preferences**: YAML-driven system preference automation
- **🔧 XDG Compliance**: Modern file organization following XDG Base Directory specification
- **🌍 Platform Support**: macOS, Linux, and Windows with automatic platform detection

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

## 🛠️ Automated Setup Scripts

The repository uses chezmoi's run scripts for automated setup:

1. **`run_once_01-install-mise.sh.tmpl`** - Install mise version manager
2. **`run_once_02-install-platform-packages.sh.tmpl`** - Platform-specific package installation
3. **`run_once_03-install-universal-tools.sh.tmpl`** - Cross-platform CLI tools (cargo/npm/go)
4. **`run_onchange_04-setup-shell-tools.sh.tmpl`** - Shell configuration and plugin setup
5. **`run_once_99-validate-setup.sh.tmpl`** - Final validation and system check

## 📦 Package Management

### Package Sources

- **mise**: Version management for programming languages (Node.js, Python, Go, Rust)
- **Cargo**: Rust-based CLI tools (ripgrep, fd, bat, eza, zoxide, sheldon)
- **Platform-specific**: Homebrew (macOS), native package managers (Linux), winget/scoop (Windows)
- **Direct downloads**: Binary downloads via chezmoi externals

### Configuration Files

- **`packages/package-definitions.yaml`** - Cross-platform package definitions
- **`packages/Brewfile.tmpl`** - macOS Homebrew packages
- **`.chezmoiexternal.yaml`** - Direct binary downloads

### Example Package Definition

```yaml
cli_tools:
  ripgrep:
    cargo: "ripgrep"
    brew: "ripgrep"
    apt: "ripgrep"
    description: "Fast grep replacement"
```

## ⚡ Shell Configuration

### File Organization

Zsh configuration uses numbered prefixes for predictable loading order:

- **01-03**: Foundation (environment, PATH, plugins)
- **10-13**: Shell initialization (completions, history, options, keybindings)
- **20-29**: Tool configurations (language-specific settings)
- **30-39**: User interface (functions, aliases)
- **90+**: Local overrides

### Plugin Management

[Sheldon](https://github.com/rossmacarthur/sheldon) manages Zsh plugins with TOML configuration:

```toml
[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"

[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"
```

## 🍎 macOS System Preferences

YAML-driven system configuration:

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

## 🔧 Common Commands

### Dotfile Management

```bash
chezmoi update                                    # Update from repository
chezmoi diff                                      # Preview changes
chezmoi edit ~/.config/zsh/01-environment.zsh    # Edit managed file
chezmoi add ~/.config/newapp/config.yaml         # Start managing new file
chezmoi apply --force                             # Force apply changes
```

### Package Updates

```bash
mise upgrade                    # Update language versions
brew upgrade                    # Update macOS packages
sudo apt upgrade               # Update Ubuntu/Debian packages
cargo install-update -a       # Update Rust tools
```

### Shell Management

```bash
sheldon lock                   # Update plugin cache
exec zsh                       # Reload shell configuration
chezmoi edit ~/.config/sheldon/plugins.toml  # Edit plugins
```

## 🌍 Platform Support

| Platform | Status | Package Manager | System Preferences |
|----------|--------|-----------------|-------------------|
| macOS | ✅ Full | Homebrew | ✅ Full |
| Linux | ✅ Full | Native (apt/dnf/pacman) | ⚠️ Limited |
| Windows | ✅ Basic | winget/scoop | ⚠️ Limited |

## 📚 Documentation

Detailed component documentation:

- [Package Management](docs/PACKAGE_MANAGEMENT.md) - Package definitions and platform handling
- [Shell Configuration](docs/SHELL_CONFIGURATION.md) - Zsh organization and customization
- [chezmoi Operations](docs/CHEZMOI_USAGE.md) - Dotfile management commands
- [macOS Preferences](docs/MACOS_SETUP.md) - System preference automation

## 📄 License

MIT License - Personal dotfiles repository, feel free to fork and adapt.

---

*Personal dotfiles focused on cross-platform compatibility and automated setup.*