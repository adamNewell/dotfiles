# Adam Newell's Dotfiles

<p align="center">
  <i>Personal dotfiles managed with chezmoi, featuring automated setup and cross-platform compatibility</i>
</p>

## 🚀 Quick Start

```bash
# Full environment setup (recommended)
curl -fsSL https://raw.githubusercontent.com/adamNewell/.dotfiles/main/setup.sh | bash

# Alternative: Direct chezmoi installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply adamNewell/dotfiles
```

## ✨ Features

- **🏠 chezmoi Management**: Templated dotfile management with cross-platform support
- **📦 Smart Package Management**: Platform-aware installation (Homebrew, apt, dnf, winget/scoop)
- **⚡ Modern Shell Setup**: Organized Zsh configuration with Sheldon plugin manager
- **🎨 macOS Preferences**: YAML-driven system preference automation
- **🔧 XDG Compliance**: Modern file organization following XDG Base Directory specification
- **🌍 Cross-Platform**: Full support for macOS, Linux, and Windows

## 📚 What Are Dotfiles?

Dotfiles are configuration files that customize your development environment. They're called "dotfiles" because they typically start with a dot (`.gitconfig`, `.zshrc`, `.vimrc`) and are stored in your home directory or `~/.config`.

This repository uses [chezmoi](https://www.chezmoi.io/) to manage dotfiles across multiple machines, providing templating, cross-platform support, and automated setup scripts.

### Why Use a Dotfile System?

By using a dotfile system, you can:
- **⚡ Set up new machines in minutes** - One command gets you from zero to fully configured
- **🔄 Keep settings synced** across multiple environments (work laptop, personal machine, servers)
- **⏪ Easily roll back changes** with Git version control
- **🛡️ Never lose configurations** - everything is backed up and versioned

Once set up, you can SSH into a fresh system, run the install script, and be productive within minutes.

## 🏗️ Repository Structure

```
.dotfiles/
├── .local/share/chezmoi/           # chezmoi source directory
│   ├── dot_config/                 # ~/.config configurations
│   │   ├── git/                    # Git configuration
│   │   ├── kitty/                  # Kitty terminal emulator
│   │   ├── nvim/                   # Neovim editor
│   │   ├── sheldon/                # Sheldon plugin manager
│   │   ├── tmux/                   # tmux multiplexer
│   │   └── zsh/                    # Organized Zsh configuration
│   ├── packages/                   # Package management
│   │   ├── package-definitions.yaml# Cross-platform packages
│   │   └── Brewfile.tmpl          # Homebrew packages
│   ├── macos-defaults.yaml         # macOS system preferences
│   ├── run_once_*.sh.tmpl          # Setup scripts
│   └── .chezmoiexternal.yaml       # Binary downloads
├── .config/chezmoi/                # chezmoi configuration
└── docs/                           # Documentation
```

## 🔧 Package Management

### Automated Setup Scripts

The repository uses chezmoi's run scripts for automated setup:

1. **`run_once_01-install-mise.sh.tmpl`** - Install mise version manager
2. **`run_once_02-install-platform-packages.sh.tmpl`** - Platform-specific packages
3. **`run_once_03-install-universal-tools.sh.tmpl`** - Cross-platform CLI tools
4. **`run_onchange_04-setup-shell-tools.sh.tmpl`** - Shell configuration
5. **`run_once_99-validate-setup.sh.tmpl`** - Final validation

### Package Sources

- **mise**: Version management for programming languages
- **Cargo**: Rust-based CLI tools (ripgrep, fd, bat, eza, zoxide)
- **Platform managers**: Homebrew (macOS), apt/dnf (Linux), winget/scoop (Windows)
- **Direct downloads**: Binary downloads via chezmoi externals

### Platform Support

| Platform | Status | Package Manager | System Preferences |
|----------|--------|-----------------|-------------------|
| macOS | ✅ Full | Homebrew | ✅ Full |
| Linux | ✅ Full | Native (apt/dnf/pacman) | ⚠️ Limited |
| Windows | ✅ Basic | winget/scoop | ⚠️ Limited |

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

## 🔐 Security

This repository follows security best practices:

- **🔒 No sensitive data** - API keys, passwords, and private keys are never committed
- **📝 `.gitignore` protection** - Sensitive files are automatically excluded
- **🛡️ Template-based configs** - chezmoi templates allow for secure, machine-specific values
- **🔐 GPG support** - chezmoi supports GPG encryption for truly sensitive data when needed

Always review configurations before committing to ensure no sensitive information is included.

## 📚 Documentation

For detailed component documentation, see:

- [Package Management](docs/PACKAGE_MANAGEMENT.md) - Package definitions and platform handling
- [Shell Configuration](docs/SHELL_CONFIGURATION.md) - Zsh organization and customization
- [chezmoi Operations](docs/CHEZMOI_USAGE.md) - Dotfile management commands
- [macOS Preferences](docs/MACOS_SETUP.md) - System preference automation

## 🎯 Forking & Customization

While you're welcome to fork this repository as a starting point, dotfiles are highly personal configurations. What works for one developer may not suit another's workflow.

### Recommendations:

- **📖 Read before using** - Understand what each configuration does before applying it
- **🛠️ Customize gradually** - Start with basic configs and add features as needed
- **✅ Test thoroughly** - Always test configurations in a safe environment first
- **📝 Document changes** - Keep track of your customizations for future reference

### Inspiration Sources:

- [webpro/awesome-dotfiles](https://github.com/webpro/awesome-dotfiles) - Curated dotfile resources
- [dotfiles.github.io](https://dotfiles.github.io/) - Dotfile gallery and tutorials
- [r/unixporn](https://www.reddit.com/r/unixporn/) - Community showcases

## 📄 License

MIT License - Personal dotfiles repository, feel free to fork and adapt.

---

*Personal dotfiles focused on cross-platform compatibility and automated setup.*
