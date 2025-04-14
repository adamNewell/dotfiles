# Personal Dotfiles

My personal dotfiles for macOS, managed with GNU Stow.

## Prerequisites

- macOS 11 (Big Sur) or later
- Apple Silicon Mac

## Installation

### Direct Installation

```zsh
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/adamNewell/dotfiles/main/install.zsh)"
```

Or if you've already cloned the repository:

```zsh
./install.zsh
```

### Restore from Backup

To restore your system from a previous backup:

```zsh
./restore.zsh ~/.dotfiles_backup/YYYYMMDD_HHMMSS
```

## Directory Structure

```
.
├── .config/           # XDG config directory
├── .local/            # XDG data and state directories
├── home/              # Files that belong in $HOME
├── packages/          # Package-specific configurations
└── scripts/           # Installation and utility scripts
    └── lib/           # Shared shell functions
```

## Features

- System compatibility check (macOS version and architecture)
- Installation of Xcode Command Line Tools
- Homebrew package management
- Automatic backup of existing configuration files
- GNU Stow for managing symlinks
- macOS system preferences configuration
- Backup and restore functionality

## Configuration

### Package Management

The installation process uses Homebrew to install packages defined in `packages/brew/Brewfile`. This includes:

- Command line tools
- GUI applications (via Homebrew Cask)
- Mac App Store applications (via mas)

### macOS Configuration

System preferences are configured in `packages/macos/scripts/defaults.sh`.

## Backup and Restore

### Automatic Backup

During installation, your existing configuration files are automatically backed up to `~/.dotfiles_backup/TIMESTAMP/`. This includes:

- Configuration files
- Shell history
- Application settings
- List of installed Homebrew packages

### Manual Restore

To restore your system from a backup:

1. Run the restore script with the backup directory:
   ```zsh
   ./restore.zsh ~/.dotfiles_backup/YYYYMMDD_HHMMSS
   ```
2. The script will:
   - Restore your configuration files
   - Show you which Homebrew packages were installed
   - Optionally remove any packages that were installed during the original setup

### Restore Script

```zsh
./restore.zsh [options] BACKUP_DIR

Options:
    -h, --help                Show help message
    --no-homebrew-cleanup     Skip Homebrew package cleanup prompt
    --force                   Skip all confirmation prompts
    --dry-run                 Show what would be restored without making changes

Arguments:
    BACKUP_DIR    Path to the backup directory
                  (e.g., ~/.dotfiles_backup/20240321_123456)

Examples:
    ./restore.zsh ~/.dotfiles_backup/20240321_123456            # Normal restore
    ./restore.zsh --force ~/.dotfiles_backup/20240321_123456    # Restore without prompts
    ./restore.zsh --dry-run ~/.dotfiles_backup/20240321_123456  # Preview restore
```

## Customization

To customize the installation:

1. Fork this repository
2. Modify the Brewfile to add/remove packages
3. Update the macOS defaults in `packages/macos/scripts/defaults.sh`
4. Add your own configuration files to the appropriate directories

## Updating

To update your dotfiles:

1. Pull the latest changes:
   ```zsh
   cd ~/.dotfiles
   git pull
   ```
2. Run the install script again:
   ```zsh
   ./install.zsh
   ```

## Command Line Options

### Install Script

```zsh
./install.zsh [options]

Options:
    -h, --help               Show help message
    --no-homebrew            Skip Homebrew installation and package management
    --no-macos-defaults      Skip setting macOS defaults
    --no-backup              Skip backing up existing files
    --no-services            Skip starting services (e.g., skhd)

Examples:
    ./install.zsh                 # Full installation
    ./install.zsh --no-backup     # Install without backing up existing files
    ./install.zsh --no-homebrew --no-macos-defaults   # Minimal installation
```

### Restore Script

```zsh
./restore.zsh [options] BACKUP_DIR

Options:
    -h, --help                 Show help message
    --no-homebrew-cleanup      Skip Homebrew package cleanup prompt
    --force                    Skip all confirmation prompts
    --dry-run                  Show what would be restored without making changes

Arguments:
    BACKUP_DIR     Path to the backup directory
                   (e.g., ~/.dotfiles_backup/20240321_123456)

Examples:
    ./restore.zsh ~/.dotfiles_backup/20240321_123456           # Normal restore
    ./restore.zsh --force ~/.dotfiles_backup/20240321_123456   # Restore without prompts
    ./restore.zsh --dry-run ~/.dotfiles_backup/20240321_123456 # Preview restore
```

## Credits

- [GNU Stow](https://www.gnu.org/software/stow/) for symlink management
- [Homebrew](https://brew.sh/) for package management
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)