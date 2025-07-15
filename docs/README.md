# Documentation Index

This directory contains comprehensive documentation for Adam Newell's dotfiles repository.

## 📚 Main Documentation

### Core Guides

- **[Package Management](PACKAGE_MANAGEMENT.md)** - Cross-platform package installation and management
- **[Shell Configuration](SHELL_CONFIGURATION.md)** - Zsh setup, plugin management, and customization  
- **[chezmoi Usage](CHEZMOI_USAGE.md)** - Complete guide to using chezmoi for dotfile management
- **[macOS Setup](MACOS_SETUP.md)** - macOS-specific configuration and system preferences

## 🛠️ Component Documentation

### Editor Configuration

The `vim/` directory contains detailed documentation for Neovim configuration:

- **[Neovim Overview](vim/README.md)** - Main Neovim configuration guide
- **[Plugin Documentation](vim/plugins/)** - Individual plugin configurations and usage

### Key Neovim Plugins

Essential plugins with dedicated documentation:

- **[Mason](vim/plugins/mason.md)** - LSP server, DAP server, linter, and formatter installer
- **[Telescope](vim/plugins/telescope.md)** - Fuzzy finder and picker
- **[Treesitter](vim/plugins/treesitter.md)** - Advanced syntax highlighting and text objects
- **[LSP Configuration](vim/plugins/nvim-lspconfig.md)** - Language Server Protocol setup
- **[Completion](vim/plugins/nvim-cmp.md)** - Autocompletion engine
- **[Git Integration](vim/plugins/gitsigns.md)** - Git status in editor

## 🚀 Quick Start Guides

### New User Setup

1. **[Installation](#installation)** - Get started with a single command
2. **[Package Management](PACKAGE_MANAGEMENT.md#quick-start)** - Understand the package system
3. **[Shell Configuration](SHELL_CONFIGURATION.md#overview)** - Learn the shell setup
4. **[chezmoi Basics](CHEZMOI_USAGE.md#quick-reference)** - Essential chezmoi commands

### Daily Usage

- **[Maintenance Commands](CHEZMOI_USAGE.md#common-operations)** - Regular maintenance tasks
- **[Package Updates](PACKAGE_MANAGEMENT.md#updating-tools)** - Keep everything current
- **[Shell Customization](SHELL_CONFIGURATION.md#customization)** - Personalizing your environment

## 🔧 Advanced Topics

### System Administration

- **[macOS System Preferences](MACOS_SETUP.md#system-preferences)** - Automated system configuration
- **[Cross-Platform Support](PACKAGE_MANAGEMENT.md#platform-differences)** - Multi-OS compatibility
- **[Security Configuration](MACOS_SETUP.md#security-privacy)** - Security best practices

### Development Workflow

- **[Version Management](PACKAGE_MANAGEMENT.md#programming-languages)** - Managing language versions with mise
- **[Git Configuration](CHEZMOI_USAGE.md#templates)** - Templated git setup
- **[Editor Integration](vim/README.md)** - Complete development environment

### Customization & Extension

- **[Adding New Tools](SHELL_CONFIGURATION.md#adding-new-tools)** - Extending the configuration
- **[Template Usage](CHEZMOI_USAGE.md#templates)** - Advanced chezmoi templating
- **[Package Definitions](PACKAGE_MANAGEMENT.md#adding-new-tools)** - Adding new packages

## 🔍 Reference

### Command Reference

```bash
# Core chezmoi commands
chezmoi init --apply adamNewell/dotfiles  # Initial setup
chezmoi update                            # Update from repository
chezmoi diff                              # See pending changes
chezmoi edit <file>                       # Edit managed file

# Package management
mise list                                 # Show installed language versions
brew upgrade                              # Update macOS packages (macOS)
sheldon lock                             # Update shell plugins

# Shell management
exec zsh                                  # Reload shell configuration
source ~/.config/zsh/01-environment.zsh  # Reload specific config
```

### File Structure Reference

```
.dotfiles/
├── .local/share/chezmoi/          # chezmoi source directory
│   ├── dot_config/                # Configuration files
│   ├── packages/                  # Package definitions
│   ├── run_once_*.sh.tmpl         # Setup scripts
│   └── macos-defaults.yaml        # macOS preferences
├── .config/chezmoi/               # chezmoi configuration
└── docs/                          # This documentation
    ├── README.md                  # This file
    ├── *.md                       # Main guides
    └── vim/                       # Neovim documentation
```

### Platform Support

| Feature | macOS | Linux | Windows |
|---------|-------|-------|---------|
| Core dotfiles | ✅ Full | ✅ Full | ✅ Basic |
| Package management | ✅ Homebrew | ✅ Native | ✅ winget/scoop |
| System preferences | ✅ Full | ⚠️ Limited | ⚠️ Limited |
| Shell configuration | ✅ Full | ✅ Full | ✅ Basic |
| Development tools | ✅ Full | ✅ Full | ✅ Good |

## 🤔 FAQ

### Common Questions

**Q: How do I add a new configuration file?**
A: Use `chezmoi add <file>` to start managing it. See [chezmoi Usage](CHEZMOI_USAGE.md#adding-new-configuration).

**Q: How do I install additional packages?**
A: Edit the package definitions in `packages/package-definitions.yaml`. See [Package Management](PACKAGE_MANAGEMENT.md#adding-new-tools).

**Q: How do I customize the shell configuration?**
A: Create local overrides in `~/.config/zsh/90-local.zsh`. See [Shell Configuration](SHELL_CONFIGURATION.md#local-overrides).

**Q: How do I update everything?**
A: Run `chezmoi update` for dotfiles, `mise upgrade` for languages, and platform-specific update commands for packages.

### Troubleshooting

For troubleshooting guides, see:
- [chezmoi Troubleshooting](CHEZMOI_USAGE.md#troubleshooting)
- [Shell Troubleshooting](SHELL_CONFIGURATION.md#troubleshooting)
- [macOS Troubleshooting](MACOS_SETUP.md#troubleshooting)
- [Package Troubleshooting](PACKAGE_MANAGEMENT.md#troubleshooting)

## 🔗 External Resources

### Official Documentation

- [chezmoi Documentation](https://www.chezmoi.io/)
- [Sheldon Documentation](https://sheldon.cli.rs/)
- [mise Documentation](https://mise.jdx.dev/)
- [Neovim Documentation](https://neovim.io/doc/)

### Community Resources

- [chezmoi Community](https://github.com/twpayne/chezmoi/discussions)
- [Awesome dotfiles](https://github.com/webpro/awesome-dotfiles)
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)

---

This documentation is maintained alongside the dotfiles repository. For questions, issues, or contributions, please see the main [README](../README.md).