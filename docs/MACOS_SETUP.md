# macOS Setup Guide

This guide covers the macOS-specific setup and configuration included in these dotfiles.

## Overview

The macOS setup provides:
- **Elegant system preferences** configuration via Python and YAML
- **Comprehensive package management** through Homebrew
- **Development environment** setup
- **Security and productivity** optimizations

## System Preferences

### YAML-Driven Configuration

Instead of raw `defaults` commands, this setup uses a clean YAML configuration file (`macos-defaults.yaml`) that's processed by a Python script:

```yaml
# Human-readable configuration
finder:
  show_hidden_files: true
  show_all_extensions: true
  default_view: "column"

dock:
  icon_size: 36
  minimize_effect: "scale"
  hide_recent_apps: true

safari:
  show_full_url: true
  enable_develop_menu: true
  disable_java: true
```

### Applied Settings

#### General UI/UX
- Disable focus ring animations for cleaner interface
- Expand save/print panels by default
- Save to disk instead of iCloud by default
- Disable smart quotes/dashes (better for coding)
- Show scrollbars only when scrolling

#### Input Devices
- Enable tap-to-click on trackpad
- Full keyboard access for all controls
- Increase Bluetooth audio quality

#### Display & Screenshots
- Require password immediately after sleep
- Save screenshots to Downloads folder in PNG format
- Disable shadows in screenshots
- Enable HiDPI display modes

#### Finder
- Allow quitting Finder with ⌘+Q
- Disable window animations for speed
- Show hidden files and all file extensions
- Show status bar and path bar
- Keep folders on top when sorting
- Disable file extension change warnings
- Use column view by default
- Prevent .DS_Store files on network/USB volumes

#### Dock
- Set icon size to 36 pixels for optimal visibility
- Use scale effect for minimizing
- Minimize windows into application icon
- Show indicator lights for running apps
- Disable launch animations for speed
- Fast Mission Control animations (0.1s)
- Don't automatically rearrange Spaces
- Translucent hidden app icons
- Hide recent applications

#### Safari
- Show full URLs in address bar
- Set homepage to about:blank for fast loading
- Prevent automatic opening of "safe" downloads
- Enable Develop menu and Web Inspector
- Disable Java for security
- Block popup windows
- Enable "Do Not Track"

#### Activity Monitor
- Show main window on launch
- Display CPU usage in dock icon
- Show all processes by default
- Sort by CPU usage

#### App Store
- Enable automatic update checking
- Check for updates daily
- Download updates automatically
- Install critical updates automatically

### Customizing Settings

#### Modifying Preferences

Edit the YAML configuration file:

```bash
chezmoi edit ~/.local/share/chezmoi/macos-defaults.yaml
```

Add or modify settings:

```yaml
# Add new settings
text_edit:
  plain_text_mode: true
  utf8_encoding: true

# Modify existing settings
dock:
  icon_size: 48  # Larger dock icons
  show_recents: true  # Show recent apps
```

#### Adding New Settings

1. **Find the defaults command** you want to add:
   ```bash
   # Example: Enable Safari debug menu
   defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
   ```

2. **Add to YAML configuration**:
   ```yaml
   safari:
     enable_debug_menu: true
   ```

3. **Add mapping to Python script**:
   ```python
   # In CONFIG_MAP dictionary
   'safari.enable_debug_menu': ('com.apple.Safari', 'IncludeInternalDebugMenu', 'bool'),
   ```

## Package Management

### Homebrew Integration

The dotfiles automatically install and configure Homebrew with a templated Brewfile.

#### Package Categories

**System Utilities**:
- curl, wget, tree, parallel
- pigz, zopfli, p7zip (compression tools)
- pv (pipe viewer), trash (safe deletion)
- openssh, mackup (backup tool)

**Development Tools**:
- git, git-extras, git-flow, git-lfs
- hub (GitHub CLI), tmux, neovim
- docker, node (latest LTS)

**Shell Enhancement**:
- bash, zsh, zsh-completions
- oh-my-posh (prompt)
- findutils, gnu-sed, grep, gawk (GNU tools)

**CLI Tools** (managed by cross-platform definitions):
- ripgrep, fd, bat, eza (modern Unix tools)
- fzf (fuzzy finder), jq/yq (JSON/YAML processors)
- git-delta (better git diff)

**Applications**:
- kitty (terminal emulator)
- firefox@developer-edition
- obsidian (note-taking)
- visual-studio-code
- sublime-text

**Fonts**:
- font-hack-nerd-font
- font-meslo-lg-nerd-font

#### Managing Packages

**Add new packages**:

```bash
# Edit package definitions
chezmoi edit ~/.local/share/chezmoi/.chezmoidata.yaml

# Or edit Brewfile template directly (if you have one)
chezmoi edit ~/.local/share/chezmoi/os/macos/Brewfile.tmpl
```

**Install new packages**:

```bash
# Re-run package installation
chezmoi apply --force --include=scripts

# Or manually with Homebrew
brew bundle --file=~/.local/share/chezmoi/packages/Brewfile
```

## Development Environment

### Programming Languages

**Version Management with mise**:
- Node.js (latest LTS)
- Python (latest stable)
- Go (latest stable)
- Rust (latest stable)

**Configuration**:
```bash
# Check installed versions
mise list

# Install specific version
mise install nodejs@18.18.0

# Set global version
mise global nodejs@18.18.0
```

### CLI Tools

**Modern Unix Tools** (installed via cargo):
- `eza` - Modern ls replacement with colors and icons
- `fd` - Fast find replacement
- `ripgrep` - Fast grep replacement
- `bat` - Cat with syntax highlighting
- `zoxide` - Smart cd with frecency

**Development Tools**:
- `git-delta` - Better git diff viewer
- `lazygit` - Terminal UI for git
- `sheldon` - Fast Zsh plugin manager

### Git Configuration

**Global Settings**:
- User name and email (templated)
- Default branch: main
- Push default: simple
- Credential helper: osxkeychain

**Aliases**:
- `st` - status
- `co` - checkout
- `br` - branch
- `ci` - commit
- `unstage` - reset HEAD --
- `last` - log -1 HEAD
- `visual` - !gitk

## Security & Privacy

### System Security

**Screen Security**:
- Require password immediately after sleep
- Screen saver activation delay: 0 seconds

**Safari Security**:
- Disable Java (security risk)
- Block popup windows
- Enable "Do Not Track"
- Warn about fraudulent websites

**Privacy Settings**:
- Disable sending search queries to Apple
- Disable automatic "safe" file opening

### Finder Security

**File Visibility**:
- Show hidden files (for development awareness)
- Show all file extensions (prevent spoofing)
- Disable extension change warnings (for developers)

**Network Security**:
- Prevent .DS_Store creation on network volumes
- Prevent .DS_Store creation on USB volumes

## Automation & Scripts

### Setup Process

The macOS setup runs automatically through chezmoi scripts:

1. **`run_once_05-setup-macos-defaults.py.tmpl`**:
   - Applies all system preferences
   - Handles sudo requirements
   - Restarts affected applications
   - Validates successful application

### Manual Operations

**Re-run system preferences**:
```bash
~/.local/share/run_once_05-setup-macos-defaults.py
```

**Apply only specific settings**:
```bash
# Edit and run manually
python3 ~/.local/share/chezmoi/run_once_05-setup-macos-defaults.py.tmpl
```

## Productivity Features

### Finder Enhancements

- **Column view** for hierarchical navigation
- **Status bar** showing item count and available space
- **Hidden files visible** for development work
- **Downloads as default location** for new windows
- **Folders on top** for better organization

### Dock Optimization

- **36px icons** for optimal screen usage
- **Scale minimize effect** for visual consistency
- **No recent apps** to reduce clutter
- **Fast animations** for snappy feel

### Keyboard & Trackpad

- **Tap to click** enabled for faster navigation
- **Full keyboard access** for accessibility
- **Optimized key repeat** rates

## Troubleshooting

### Common Issues

**Settings not applying**:
```bash
# Check for running System Preferences
pkill "System Preferences"

# Re-run with sudo
sudo ~/.local/share/run_once_05-setup-macos-defaults.py
```

**Homebrew installation fails**:
```bash
# Check Homebrew installation
brew doctor

# Reinstall if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Package conflicts**:
```bash
# Clean up Homebrew
brew cleanup
brew autoremove

# Re-run package installation
chezmoi apply --force --include=scripts
```

### Reset Options

**Reset system preferences**:
```bash
# Reset to macOS defaults (use with caution)
defaults delete com.apple.finder
defaults delete com.apple.dock
killall Finder Dock
```

**Reset Homebrew**:
```bash
# Uninstall all packages
brew list | xargs brew uninstall --force

# Reinstall from Brewfile
brew bundle --file=~/.local/share/chezmoi/packages/Brewfile
```

## Customization

### Personal Preferences

Create local overrides without affecting the main configuration:

```bash
# Create local macOS settings
cat > ~/.local/bin/local-macos-setup << 'EOF'
#!/bin/bash
# Personal macOS settings

# Larger dock
defaults write com.apple.dock tilesize -int 48

# Different screenshot location
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

killall Dock
EOF

chmod +x ~/.local/bin/local-macos-setup
```

### Organization-Specific Settings

For work environments, create organization-specific configurations:

```yaml
# work-macos-defaults.yaml
security:
  require_password_delay: 0
  enable_firewall: true

productivity:
  disable_notifications_during_focus: true
  hide_menu_bar_clock: false
```

This macOS setup provides a solid foundation for a productive development environment while maintaining security and performance optimization.
