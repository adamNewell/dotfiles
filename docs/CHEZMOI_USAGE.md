# chezmoi Usage Guide

This guide covers how to use chezmoi effectively with this dotfiles repository.

## Overview

[chezmoi](https://www.chezmoi.io/) is a modern dotfile manager that handles:
- **Templating**: Platform-specific configurations
- **Secret management**: Secure handling of sensitive data
- **Cross-platform support**: Works on macOS, Linux, and Windows
- **Automated setup**: Run scripts for complete machine provisioning
- **State management**: Tracks changes and applies updates intelligently

## Quick Reference

### Essential Commands

```bash
# Initialize and apply dotfiles (new machine)
chezmoi init --apply adamNewell/dotfiles

# Update from repository
chezmoi update

# See what would change
chezmoi diff

# Apply pending changes
chezmoi apply

# Edit a configuration file
chezmoi edit ~/.config/zsh/01-environment.zsh

# Add a new file to management
chezmoi add ~/.config/newapp/config.yaml

# Re-run setup scripts
chezmoi apply --force
```

### File Management

```bash
# Check status of managed files
chezmoi status

# View managed files
chezmoi managed

# Remove a file from management
chezmoi remove ~/.config/oldapp/config.yaml

# Forget (untrack) a file without deleting
chezmoi forget ~/.config/temp/file.conf
```

## Repository Structure

### Source Directory

All chezmoi source files are in `.local/share/chezmoi/`:

```
.local/share/chezmoi/
├── dot_config/                 # Maps to ~/.config/
│   ├── git/
│   │   ├── config             # Static file
│   │   └── gitcommit.tmpl     # Template file
│   └── zsh/
│       └── 01-environment.zsh
├── dot_zshenv                  # Maps to ~/.zshenv
├── run_once_*.sh.tmpl          # Setup scripts (run once)
├── run_onchange_*.sh.tmpl      # Scripts that run when changed
├── .chezmoiexternal.yaml       # External file downloads
└── .chezmoidata.yaml           # Template data and package definitions
```

### File Naming Convention

chezmoi uses special prefixes to indicate file types and behavior:

- **`dot_`**: Creates files/directories starting with `.`
  - `dot_config` → `~/.config`
  - `dot_zshenv` → `~/.zshenv`

- **`.tmpl`**: Template files processed by chezmoi
  - `gitcommit.tmpl` → `gitcommit` (with variables substituted)
  - `Brewfile.tmpl` → `Brewfile` (platform-specific content)

- **`run_once_`**: Scripts that run once per machine
  - `run_once_01-install-mise.sh.tmpl`

- **`run_onchange_`**: Scripts that run when they change
  - `run_onchange_04-setup-shell-tools.sh.tmpl`

- **Special files**:
  - `.chezmoiexternal.yaml`: External downloads
  - `.chezmoidata.yaml`: Template data
  - `.chezmoiignore`: Files to ignore

## Templates

### Template Variables

Templates have access to these variables:

```bash
# Platform detection
{{ .chezmoi.os }}          # "darwin", "linux", "windows"
{{ .chezmoi.arch }}        # "amd64", "arm64"

# System information
{{ .chezmoi.hostname }}    # Machine hostname
{{ .chezmoi.username }}    # Current username

# Custom data (from .chezmoidata.yaml)
{{ .cli_tools.ripgrep.description }}
{{ .platform_packages.darwin.system }}
```

### Template Examples

#### Conditional Content

```bash
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific configuration
export HOMEBREW_PREFIX="/opt/homebrew"
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific configuration  
export PATH="/usr/local/bin:$PATH"
{{- end }}
```

#### Package Installation

```bash
{{- if eq .chezmoi.os "darwin" }}
# Install packages from package definitions
{{- range $pkg := (index .platform_packages.darwin "system") }}
brew '{{ $pkg }}'
{{- end }}
{{- end }}
```

#### Secret Management

```bash
# Use with external secret managers
[github]
user = "{{ .github.user }}"
token = "{{ (onepasswordItemFields "GitHub Token").password.value }}"
```

## Run Scripts

### Script Types

#### `run_once_` Scripts
Run exactly once per machine (tracked in `~/.local/share/chezmoi/chezmoistate.boltdb`):

- `run_once_01-install-mise.sh.tmpl` - Install version manager
- `run_once_02-install-platform-packages.sh.tmpl` - Platform packages
- `run_once_03-install-universal-tools.sh.tmpl` - CLI tools
- `run_once_05-setup-macos-defaults.py.tmpl` - macOS preferences
- `run_once_99-validate-setup.sh.tmpl` - System validation

#### `run_onchange_` Scripts
Run when the script content changes:

- `run_onchange_04-setup-shell-tools.sh.tmpl` - Shell configuration

### Script Execution

```bash
# Run all scripts (including already-run ones)
chezmoi apply --force

# Run specific script type
chezmoi execute-template < .local/share/chezmoi/run_once_01-install-mise.sh.tmpl | bash

# Check which scripts would run
chezmoi diff --include=scripts
```

## External Files

### Configuration

External files are defined in `.chezmoiexternal.yaml`:

```yaml
# Download binary tools not available via package managers
".local/bin/age":
  type: "archive"
  url: "https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-{{ .chezmoi.os }}-{{ .chezmoi.arch }}.tar.gz"
  stripComponents: 1
  include: ["age"]
  executable: true

".local/bin/fzf":
  type: "file"
  url: "https://github.com/junegunn/fzf/releases/latest/download/fzf-{{ .chezmoi.os }}_{{ .chezmoi.arch }}.tar.gz"
  executable: true
```

### Management

```bash
# Update external files
chezmoi apply --include=externals

# Re-download external files
chezmoi apply --force --include=externals
```

## Data Management

### Template Data

Data for templates is stored in `.chezmoidata.yaml`:

```yaml
# Package definitions available as {{ .cli_tools }}
cli_tools:
  ripgrep:
    cargo: "ripgrep"
    brew: "ripgrep"
    description: "Fast grep replacement"

platform_packages:
  darwin:
    system:
      - curl
      - wget
      - tree
```

### Using Data in Templates

```bash
# Access package information
{{ .cli_tools.ripgrep.description }}

# Iterate over packages
{{- range $name, $def := .cli_tools }}
echo "Installing {{ $name }}: {{ $def.description }}"
{{- end }}

# Platform-specific data
{{- range $pkg := (index .platform_packages.darwin "system") }}
brew install {{ $pkg }}
{{- end }}
```

## Advanced Usage

### Ignoring Files

Create `.chezmoiignore` to exclude files:

```
# Ignore README files
README.md
docs/

# Ignore on specific platforms
{{ if ne .chezmoi.os "darwin" }}
.macos
{{ end }}

# Ignore private files
*.local
```

### Machine-Specific Configuration

For machine-specific settings that shouldn't be in version control:

```bash
# Create local configuration
chezmoi edit --apply ~/.config/zsh/90-local.zsh

# This creates a file only on this machine
```

### Secret Management

#### With 1Password

```bash
# Install 1Password CLI
# Configure in template:
token = "{{ (onepasswordItemFields "GitHub API").password.value }}"
```

#### With Built-in Prompting

```bash
# Prompt for values
email = "{{ promptStringOnce . "email" "Email address" }}"
```

### Debugging

#### Template Debugging

```bash
# Execute template to see output
chezmoi execute-template < .local/share/chezmoi/dot_config/git/config.tmpl

# Check template data
chezmoi data
```

#### Dry Run

```bash
# See what would change without applying
chezmoi diff

# Verbose output
chezmoi apply --dry-run --verbose
```

#### State Management

```bash
# Check chezmoi state
chezmoi state

# Reset state (will re-run all run_once scripts)
chezmoi state delete-bucket --bucket=entryState
```

## Common Workflows

### Adding New Configuration

1. **Create the configuration file**:
   ```bash
   # Create new app config
   mkdir -p ~/.config/newapp
   echo "setting=value" > ~/.config/newapp/config.yaml
   ```

2. **Add to chezmoi**:
   ```bash
   chezmoi add ~/.config/newapp/config.yaml
   ```

3. **Edit if needed**:
   ```bash
   chezmoi edit ~/.config/newapp/config.yaml
   ```

4. **Commit changes**:
   ```bash
   cd ~/.local/share/chezmoi
   git add .
   git commit -m "Add newapp configuration"
   git push
   ```

### Platform-Specific Files

1. **Create template**:
   ```bash
   chezmoi add --template ~/.config/app/config.yaml
   ```

2. **Edit with conditionals**:
   ```bash
   chezmoi edit ~/.config/app/config.yaml
   # Add platform-specific content with {{ if eq .chezmoi.os "darwin" }}
   ```

### Updating Packages

1. **Edit package definitions**:
   ```bash
   chezmoi edit ~/.local/share/chezmoi/.chezmoidata.yaml
   ```

2. **Apply changes**:
   ```bash
   chezmoi apply
   ```

3. **Re-run package installation if needed**:
   ```bash
   chezmoi apply --force --include=scripts
   ```

## Best Practices

1. **Test changes** on a VM or separate user account first
2. **Use templates** for platform-specific configurations
3. **Keep secrets** out of the repository (use secret managers)
4. **Document custom functions** and configurations
5. **Regular backups** of chezmoi state and repository
6. **Version control** all changes with meaningful commit messages
7. **Use run_once scripts** for one-time setup tasks
8. **Use run_onchange scripts** for configuration that needs updates

## Troubleshooting

### Common Issues

1. **Permission errors**: Check file permissions and ownership
2. **Template errors**: Use `chezmoi execute-template` to debug
3. **Script failures**: Check script logs and run manually for debugging
4. **State issues**: Reset state if run_once scripts aren't working

### Recovery

```bash
# Reset chezmoi completely
chezmoi purge

# Re-initialize
chezmoi init --apply adamNewell/dotfiles

# Restore from backup
cp -r ~/.local/share/chezmoi.backup ~/.local/share/chezmoi
```

This comprehensive usage guide should help you effectively manage your dotfiles with chezmoi.