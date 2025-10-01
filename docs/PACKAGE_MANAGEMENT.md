# Cross-Platform Package Management

This document describes the hybrid package management system implemented for this dotfiles repository.

## Overview

The system uses multiple package managers to provide cross-platform compatibility:

- **mise/asdf**: Universal version management for programming languages
- **Platform-specific managers**: Homebrew (macOS), apt/dnf/pacman (Linux), winget/scoop (Windows)
- **Language-specific managers**: cargo (Rust), npm (Node.js), go install (Go)
- **chezmoi externals**: Direct binary downloads for tools not available elsewhere

## Installation Order

The scripts run in this order during `chezmoi apply`:

1. `run_once_01-install-mise.sh.tmpl` - Installs mise version manager
2. `run_once_02-install-platform-packages.sh.tmpl` - Platform-specific packages
3. `run_once_03-install-universal-tools.sh.tmpl` - Language-specific CLI tools
4. `run_onchange_04-setup-shell-tools.sh.tmpl` - Shell configuration
5. `run_once_99-validate-setup.sh.tmpl` - Final validation

## Configuration Files

### `.chezmoidata.yaml`
Central configuration file defining all package definitions and versions:
- **Programming language versions** - Templated into `~/.config/mise/config.toml`
- **CLI tools** - Cross-platform package manager mappings
- **Platform-specific packages** - macOS, Linux, Windows package lists
- **Package manager priority** - Installation order preferences

```yaml
# Language versions (single source of truth)
languages:
  nodejs: "22.11.0"
  python: "3.12.0"
  golang: "1.21.0"
  rustup: "latest"

# CLI tools with package manager options
cli_tools:
  eza:
    cargo: "eza"
    brew: "eza"
    description: "Modern ls replacement"
```

### `~/.config/mise/config.toml`
Generated from `.chezmoidata.yaml` language versions. This file is templated - do not edit directly.

To update language versions:
1. Edit `.chezmoidata.yaml` in the chezmoi source directory
2. Run `chezmoi apply` to regenerate the mise config
3. Run `mise install` to install/update languages

### `.chezmoiexternal.yaml`
Direct binary downloads for tools not available via package managers:
- age (encryption)
- chezmoi (bootstrapping)
- fzf (fuzzy finder)

### Platform-specific package lists
- **macOS**: `os/macos/Brewfile.tmpl` (generated from `.chezmoidata.yaml`)
- **Linux**: Defined in `.chezmoidata.yaml` under `platform_packages.linux`
- **Windows**: Defined in `.chezmoidata.yaml` under `platform_packages.windows`

## Tool Categories

### Essential CLI Tools (Rust-based)
- `sheldon` - Zsh plugin manager
- `eza` - Modern ls replacement
- `zoxide` - Smart cd replacement
- `ripgrep` - Fast grep replacement
- `fd-find` - Modern find replacement
- `bat` - Cat with syntax highlighting
- `git-delta` - Better git diff viewer

### Development Tools
- Languages managed by mise (Node.js, Python, Go, Rust)
- Version-specific tools via mise
- Editor and development utilities

### Shell Enhancement
- Plugin management via sheldon
- XDG-compliant configurations

## Usage

### New Machine Setup
```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Initialize with your dotfiles
chezmoi init --apply <your-repo>

# 3. Restart shell
exec zsh
```

### Adding New Tools

#### Platform-specific tool
Add to `.chezmoidata.yaml` under the appropriate platform section:
```yaml
platform_packages:
  darwin:
    system:
      - your-new-tool
```

#### Universal CLI tool
Add to `.chezmoidata.yaml` under `cli_tools`:
```yaml
cli_tools:
  your-tool:
    cargo: "package-name"
    brew: "package-name"
    description: "What it does"
```

#### Version-managed language
Update version in `.chezmoidata.yaml` under `languages`:
```yaml
languages:
  nodejs: "23.0.0"  # Update version here
```
Then apply and install:
```bash
chezmoi apply      # Regenerates ~/.config/mise/config.toml
mise install       # Installs the new version
```

#### Direct binary download
Add to `.chezmoiexternal.yaml`

### Updating Tools
```bash
# Update mise-managed tools
mise upgrade

# Update platform packages
brew upgrade        # macOS
sudo apt upgrade    # Ubuntu/Debian
sudo dnf upgrade    # Fedora

# Update language-specific tools
cargo install-update -a    # Rust tools
npm update -g              # Node.js tools
```

## Platform Differences

### macOS
- Uses Homebrew for most packages
- XDG directories created manually
- `/opt/homebrew` prefix on Apple Silicon

### Linux
- Auto-detects package manager (apt/dnf/pacman/zypper)
- Native XDG support
- Distribution-specific package names

### Windows
- Prefers winget over scoop
- Limited XDG support
- PowerShell/cmd compatibility considerations

## Troubleshooting

### Missing tools
Run the validation script to identify missing tools:
```bash
~/.local/share/run_once_99-validate-setup.sh
```

### mise not working
Ensure mise is in your PATH:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Sheldon plugins not loading
Reinitialize sheldon:
```bash
sheldon lock
```

### Platform detection issues
Check chezmoi variables:
```bash
chezmoi data
```