# Documentation Reference

Personal reference documentation for Adam Newell's dotfiles repository. This serves as a quick lookup for commands, configuration structure, and troubleshooting.

## 📚 Configuration Reference

### Core Components

- **[Package Management](PACKAGE_MANAGEMENT.md)** - Package definitions, platform detection, and update commands
- **[Shell Configuration](SHELL_CONFIGURATION.md)** - Zsh file organization, plugin management, and customization patterns
- **[chezmoi Operations](CHEZMOI_USAGE.md)** - Dotfile management commands and template usage
- **[macOS Preferences](MACOS_SETUP.md)** - System preference automation and troubleshooting

### Editor Configuration

The `vim/` directory contains Neovim configuration documentation:

- **[Neovim Setup](vim/README.md)** - Configuration structure and key mappings
- **[Plugin Reference](vim/plugins/)** - Individual plugin configurations and commands

### Key Neovim Plugins

Essential plugins with dedicated documentation:

- **[Mason](vim/plugins/mason.md)** - LSP/DAP/linter/formatter installer
- **[Telescope](vim/plugins/telescope.md)** - Fuzzy finder and picker
- **[Treesitter](vim/plugins/treesitter.md)** - Syntax highlighting and text objects
- **[LSP Configuration](vim/plugins/nvim-lspconfig.md)** - Language Server Protocol setup
- **[Completion](vim/plugins/nvim-cmp.md)** - Autocompletion engine
- **[Git Integration](vim/plugins/gitsigns.md)** - Git status in editor

## 🚀 Quick Setup Reference

### Initial Setup

```bash
# Complete environment setup
curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash

# Minimal installation (essential tools only)
curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/setup.sh | bash -s -- --minimal

# Alternative: chezmoi direct installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply adamNewell/dotfiles
```

### Daily Operations

- **[Maintenance Commands](CHEZMOI_USAGE.md#common-workflows)** - Regular maintenance tasks
- **[Package Updates](PACKAGE_MANAGEMENT.md#updating-tools)** - Keep everything current
- **[Shell Customization](SHELL_CONFIGURATION.md#customization)** - Personalizing your environment

## 🔧 System Information

### Current Repository State

```bash
# Repository structure
dotfiles/
├── .local/share/chezmoi/           # Source directory (managed by chezmoi)
│   ├── dot_config/zsh/             # Zsh configuration (numbered loading order)
│   ├── packages/                   # Package definitions and Brewfile
│   ├── macos-defaults.yaml         # macOS system preferences
│   ├── run_once_*.sh.tmpl          # One-time setup scripts
│   └── run_onchange_*.sh.tmpl      # Change-triggered scripts
├── setup.sh                       # Universal installer script
└── docs/                          # This documentation
```

### Active Setup Scripts

These scripts run automatically during chezmoi installation:

- **`run_once_01-install-mise.sh.tmpl`** - Install mise version manager
- **`run_once_02-install-platform-packages.sh.tmpl`** - Platform-specific packages
- **`run_once_03-install-universal-tools.sh.tmpl`** - Cross-platform CLI tools
- **`run_onchange_04-setup-shell-tools.sh.tmpl`** - Shell configuration and plugins
- **`run_once_99-validate-setup.sh.tmpl`** - Final validation

### Platform Detection

The system automatically detects your platform and configures accordingly:

- **macOS**: Homebrew, system preferences, App Store apps
- **Linux**: Native package managers (apt, dnf, pacman, etc.)
- **Windows**: winget/scoop with PowerShell support

## 🔍 Command Reference

### Daily Operations

```bash
# Update and apply dotfiles
chezmoi update                            # Pull latest changes and apply
chezmoi diff                              # Preview changes before applying
chezmoi apply                             # Apply pending changes

# File management
chezmoi edit ~/.config/zsh/01-environment.zsh  # Edit managed file
chezmoi add ~/.config/newapp/config.yaml       # Start managing new file
chezmoi remove ~/.config/oldapp/config.yaml    # Stop managing file

# Package management
mise upgrade                              # Update language versions
brew upgrade                              # Update macOS packages
sheldon lock                             # Update shell plugins

# Shell management
exec zsh                                  # Reload shell configuration
source ~/.config/zsh/01-environment.zsh  # Reload specific config
```

### Troubleshooting Commands

```bash
# Debugging
chezmoi doctor                            # Check chezmoi configuration
chezmoi data                              # View template data
chezmoi execute-template                  # Test template syntax

# Validation
~/.local/share/chezmoi/run_once_99-validate-setup.sh  # Run setup validation
mise doctor                               # Check mise configuration
sheldon info                              # Check plugin status

# Reset/repair
chezmoi init --apply --force adamNewell/dotfiles      # Force re-initialization
chezmoi apply --force                     # Force apply all changes
rm -rf ~/.cache/sheldon && sheldon lock   # Rebuild plugin cache
```

### File Structure Reference

```
~/dotfiles/                        # Repository root
├── .local/share/chezmoi/            # chezmoi source directory
│   ├── dot_config/zsh/              # Zsh configuration (numbered loading)
│   │   ├── 01-environment.zsh       # Environment variables
│   │   ├── 02-path.zsh              # PATH configuration
│   │   ├── 03-plugins.zsh           # Plugin loading
│   │   ├── 10-completions.zsh       # Shell completions
│   │   ├── 20-tools/                # Tool-specific configurations
│   │   └── 30-functions/            # Custom functions
│   ├── .chezmoidata.yaml            # Package definitions and template data
│   ├── macos-defaults.yaml          # macOS system preferences
│   └── run_*.sh.tmpl                # Setup and maintenance scripts
├── setup.sh                        # Universal installer
└── docs/                           # This documentation
```

### Platform Support Status

| Component | macOS | Linux | Windows |
|-----------|-------|-------|---------|
| Core dotfiles | ✅ Full | ✅ Full | ✅ Basic |
| Package management | ✅ Homebrew | ✅ Native | ✅ winget/scoop |
| System preferences | ✅ Full | ⚠️ Limited | ⚠️ Limited |
| Shell configuration | ✅ Full | ✅ Full | ✅ Basic |
| Development tools | ✅ Full | ✅ Full | ✅ Good |

## 🔧 Common Operations

### Adding New Configuration

```bash
# Start managing a new file
chezmoi add ~/.config/newapp/config.yaml

# Edit it through chezmoi
chezmoi edit ~/.config/newapp/config.yaml

# Apply changes
chezmoi apply
```

### Customizing Shell Configuration

```bash
# Create local overrides (not managed by chezmoi)
echo 'export MY_VAR="value"' >> ~/.config/zsh/90-local.zsh

# Add custom functions
chezmoi edit ~/.config/zsh/30-functions/my-functions.zsh
```

### Package Management

```bash
# Add new packages to definitions
chezmoi edit ~/.local/share/chezmoi/.chezmoidata.yaml

# Update specific tool versions
mise use python@3.12
mise use node@20

# Install new Homebrew packages (macOS)
chezmoi edit ~/.local/share/chezmoi/packages/Brewfile.tmpl
```

## 🚨 Troubleshooting

### Common Issues and Solutions

**Shell not loading correctly:**
```bash
# Check zsh configuration
zsh -n ~/.config/zsh/*.zsh              # Syntax check
exec zsh                                # Reload shell
```

**Packages not installing:**
```bash
# Check platform detection
echo $DOTFILES_OS $DOTFILES_PLATFORM    # Should show your platform
chezmoi data | grep -E "(os|platform)"  # Check template data
```

**chezmoi errors:**
```bash
# Common fixes
chezmoi doctor                          # Check configuration
chezmoi apply --force                   # Force apply changes
rm -rf ~/.cache/chezmoi && chezmoi apply # Clear cache
```

### Detailed Troubleshooting

For comprehensive troubleshooting guides, see:
- [chezmoi Troubleshooting](CHEZMOI_USAGE.md#troubleshooting)
- [Shell Troubleshooting](SHELL_CONFIGURATION.md#troubleshooting)
- [macOS Troubleshooting](MACOS_SETUP.md#troubleshooting)
- [Package Troubleshooting](PACKAGE_MANAGEMENT.md#troubleshooting)

## 🔗 External Resources

### Official Documentation

- [chezmoi Documentation](https://www.chezmoi.io/) - Dotfile management
- [Sheldon Documentation](https://sheldon.cli.rs/) - Zsh plugin manager
- [mise Documentation](https://mise.jdx.dev/) - Version manager
- [Neovim Documentation](https://neovim.io/doc/) - Editor configuration

### Community Resources

- [chezmoi Community](https://github.com/twpayne/chezmoi/discussions) - Support and tips
- [Awesome dotfiles](https://github.com/webpro/awesome-dotfiles) - Inspiration
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/) - Shell reference

---

*This documentation serves as a personal reference for Adam Newell's dotfiles. For questions, issues, or contributions, see the main [README](../README.md).*
