# macOS-Specific Configuration

This directory contains macOS-specific configuration files and package definitions.

## Files

- **`macos-defaults.yaml`** - System preferences and defaults configuration
- **`Brewfile.tmpl`** - Homebrew packages and applications for macOS

## Usage

These files are automatically processed during the dotfiles installation:

1. **System Defaults**: The `macos-defaults.yaml` file is processed by `run_once_05-setup-macos-defaults.py.tmpl`
2. **Package Installation**: The `Brewfile.tmpl` is processed by `run_once_02-install-platform-packages.sh.tmpl`

## Customization

To customize macOS settings:

```bash
# Edit macOS system defaults
chezmoi edit ~/.local/share/chezmoi/os/macos/macos-defaults.yaml

# Edit Homebrew packages
chezmoi edit ~/.local/share/chezmoi/os/macos/Brewfile.tmpl
```

## Future OS Support

This directory structure allows for easy addition of other operating systems:

```
os/
├── macos/          # macOS-specific files
├── linux/          # Linux-specific files (future)
└── windows/        # Windows-specific files (future)
```