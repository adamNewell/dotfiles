# Adam Newell's Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), featuring automated setup, cross-platform package management, and organized shell configuration.

## 🚀 Quick Start

### One-Command Installation

Bootstrap a new system with a single command:

```bash
sh -c "$(curl -fsLS https://raw.githubusercontent.com/adamNewell/dotfiles/main/install.sh)"
```

This will:
1. Install chezmoi (if not already installed)
2. Clone this repository to `~/.local/share/chezmoi`
3. Apply dotfiles to your home directory
4. Run automated setup scripts that:
   - Set zsh as your default shell
   - Install platform-specific package manager (Homebrew on macOS)
   - Install development tools via mise (Rust, Node.js, Python, Go)
   - Install modern CLI tools (ripgrep, fd, bat, eza, zoxide, etc.)
   - Apply platform-specific configurations

**That's it!** Chezmoi handles the entire setup automatically using `run_once_*` and `run_onchange_*` scripts.

### Post-Installation

After installation completes:

```bash
# Restart your terminal or reload shell
exec zsh

# Verify setup
chezmoi doctor

# Check what was installed
chezmoi managed
```

### Updating

```bash
# Update dotfiles and reinstall modified packages
chezmoi update

# Preview changes before applying
chezmoi diff

# Apply changes without updating
chezmoi apply
```

## 📦 Package Managers Overview

This environment uses specialized package managers for different components:

### 🏠 **chezmoi** - Dotfile Orchestrator
- **Manages**: All configuration files and coordinates installation scripts
- **Config**: [.chezmoidata.yaml](.chezmoidata.yaml), [.chezmoiexternal.yaml](.chezmoiexternal.yaml)
- **Usage**: `chezmoi apply`, `chezmoi update`, `chezmoi edit <file>`

### 🚀 **mise** - Language Version Manager
- **Manages**: Versions for Node.js, Python, Go, and Rust
- **Config**: `dot_config/mise/config.toml.tmpl` (generated from `.chezmoidata.yaml`)
- **Usage**: `mise install`, `mise use <tool>@<version>`

### 🍺 **Homebrew** - System & CLI Tools (macOS/Linux)
- **Manages**: System packages, CLI tools, GUI applications (casks), fonts
- **Config**: `os/macos/Brewfile.tmpl` (generated from `.chezmoidata.yaml`)
- **Usage**: `brew install <package>`, `brew upgrade`, `brew bundle`
- **Primary package manager** for macOS; installed automatically by setup script

### ⚡ **Sheldon** - Zsh Plugin Manager
- **Manages**: Zsh plugins (syntax highlighting, autosuggestions, completions, themes)
- **Config**: [dot_config/sheldon/plugins.toml](dot_config/sheldon/plugins.toml)
- **Usage**: `sheldon lock` (update cache), `sheldon add <plugin>`, `sheldon source` (load)
- **Why**: Fast, declarative TOML-based configuration.

### 📝 **Neovim Plugins**
- **lazy.nvim**: Plugin manager for Neovim plugins, colorschemes
  - **Config**: [dot_config/nvim/lua/adamNewell/lazy.lua](dot_config/nvim/lua/adamNewell/lazy.lua)
  - **Usage**: `:Lazy install`, `:Lazy update`, `:Lazy sync`
- **mason.nvim**: Package manager for LSP servers, DAP servers, linters, formatters
  - **Config**: [dot_config/nvim/lua/adamNewell/plugins/lsp/mason.lua](dot_config/nvim/lua/adamNewell/plugins/lsp/mason.lua)
  - **Usage**: `:Mason`, `:MasonInstall <package>`, `:MasonUpdate`

### Quick Management Commands

```bash
# Update Homebrew packages
brew upgrade

# Update Zsh plugins
sheldon lock && exec zsh

# Add a Zsh plugin
chezmoi edit ~/.config/sheldon/plugins.toml
# Add: [plugins.name]
#      github = "user/repo"
sheldon lock && exec zsh

# Update Neovim plugins and tools
nvim +Lazy update      # Update plugins
nvim +MasonUpdate      # Update LSP servers & tools
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
.
├── .chezmoi.yaml.tmpl
├── .chezmoidata.yaml
├── .chezmoiexternal.yaml
├── .chezmoiignore
├── dot_config
│   ├── fzf
│   ├── git
│   ├── kitty
│   ├── mackup
│   ├── mise
│   ├── npm
│   ├── nvim
│   ├── pip
│   ├── ripgrep
│   ├── sheldon
│   ├── tmux
│   └── zsh
├── dot_local
│   └── private_share
│       └── oh-my-posh
├── dot_zshenv
├── install.sh
├── os
│   └── macos
├── README.md
├── run_onchange_04-setup-shell-tools.sh.tmpl
├── run_once_00-set-default-shell.sh.tmpl
├── run_once_01-install-mise.sh.tmpl
├── run_once_02-install-platform-packages.sh.tmpl
├── run_once_03-install-universal-tools.sh.tmpl
├── run_once_05-setup-macos-defaults.py.tmpl
└── run_once_99-validate-setup.sh.tmpl
```
## 🛠️ Automated Setup Scripts

The repository uses chezmoi's templated run scripts for automated, idempotent setup:

1. **`run_once_00-set-default-shell.sh.tmpl`** - Set zsh as default shell
2. **`run_once_01-install-mise.sh.tmpl`** - Install mise version manager for languages
3. **`run_once_02-install-platform-packages.sh.tmpl`** - Platform-specific packages (Homebrew/apt/dnf)
4. **`run_once_03-install-universal-tools.sh.tmpl`** - Cross-platform CLI tools (cargo/npm/go)
5. **`run_onchange_04-setup-shell-tools.sh.tmpl`** - Shell plugin setup (re-runs on changes)
6. **`run_once_05-setup-macos-defaults.py.tmpl`** - macOS system preferences (macOS only)
7. **`run_once_99-validate-setup.sh.tmpl`** - Validate installation and check dependencies

Scripts are templated (`.tmpl`) to support cross-platform conditionals and variable substitution.

## 📦 Package Management

### How It Works

All package definitions live in **`.chezmoidata.yaml`**, which provides a single source of truth for cross-platform package management. Chezmoi templates read this file to generate platform-specific installation scripts.

### Package Categories

1. **Languages** (via mise): Node.js, Python, Rust, Go
2. **CLI Tools**: Cross-platform tools with fallback package managers
3. **Platform Packages**: macOS (Homebrew), Linux (apt/dnf/pacman), Windows (winget/scoop)
4. **Direct Downloads**: Binaries via `.chezmoiexternal.yaml`

### Adding New Tools

Edit `.chezmoidata.yaml`:

```yaml
cli_tools:
  your-tool:
    cargo: "package-name"      # Preferred: Rust/Cargo
    brew: "package-name"       # macOS via Homebrew
    apt: "package-name"        # Debian/Ubuntu
    dnf: "package-name"        # Fedora/RHEL
    npm: "package-name"        # Node.js ecosystem
    go: "github.com/..."       # Go install
    description: "What it does"
```

Then run `chezmoi apply` to install.

### Package Manager Priority

The system tries package managers in this order:
1. **mise** - Language version management
2. **cargo** - Fast, reliable Rust tools
3. **brew** - macOS primary
4. **apt/dnf/pacman** - Linux native
5. **npm/go** - Language ecosystems

## 🔄 Utility Scripts

### Reconcile Dotfiles

The **[reconcile-dotfiles.sh](bin/README.md)** script helps keep your dotfiles in sync with your actual system:

```bash
./bin/reconcile-dotfiles.sh
```

**What it does:**
- Scans all installed packages on your system (Homebrew, mise, cargo, npm, apt)
- Compares against `.chezmoidata.yaml` to find packages NOT in your config
- Shows an interactive list of packages to add
- Updates `.chezmoidata.yaml` with your selections
- Commits and pushes changes to your repo

**Use cases:**
- You installed tools outside of dotfiles: `brew install some-tool` → sync them back
- Monthly maintenance to catch ad-hoc installations
- Audit what's installed vs. what's tracked

See **[bin/README.md](bin/README.md)** for detailed documentation.

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

## 🔧 Common Tasks

### Daily Dotfile Management

```bash
# Update dotfiles from repository
chezmoi update

# Preview what would change
chezmoi diff

# Edit a managed file in your editor
chezmoi edit ~/.config/zsh/01-environment.zsh

# Add a new file to dotfiles
chezmoi add ~/.config/newapp/config.yaml

# Apply local changes
chezmoi apply
```

### Managing Packages

```bash
# Add a new tool to .chezmoidata.yaml, then:
chezmoi apply                  # Install via automated scripts

# Update existing packages
mise upgrade                   # Update language versions
brew upgrade                   # Update Homebrew packages (macOS)
cargo install-update -a        # Update Rust/Cargo tools
```

### Customizing Your Setup

```bash
# Edit package definitions
chezmoi edit ~/.local/share/chezmoi/.chezmoidata.yaml

# Customize zsh configuration
chezmoi edit ~/.config/zsh/31-aliases.zsh
chezmoi edit ~/.config/zsh/01-environment.zsh

# Add zsh plugins (managed by Sheldon)
chezmoi edit ~/.config/sheldon/plugins.toml
sheldon lock && exec zsh       # Update plugin cache and reload

# macOS: customize system preferences
chezmoi edit ~/.local/share/chezmoi/run_once_05-setup-macos-defaults.py.tmpl
```

### Troubleshooting

```bash
# Check chezmoi health
chezmoi doctor

# View what chezmoi would do
chezmoi apply --dry-run --verbose

# Re-run setup scripts (useful after adding packages)
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply

# Reset to repository state
chezmoi apply --force
```

## 🌍 Platform Support

| Platform | Status  | Package Manager         | System Preferences |
|----------|---------|-------------------------|--------------------|
| macOS    | ✅ Full  | Homebrew                | ✅ Full            |
| Linux    | ✅ Full  | Native (apt/dnf/pacman) | ⚠️ Limited         |
| Windows  | ✅ Basic | winget/scoop            | ⚠️ Limited         |

## 🎯 Key Features

### For New Users

- **One-line installation**: Get a full dev environment in minutes
- **Sensible defaults**: Carefully curated tools and configurations
- **Easy customization**: All config in predictable locations
- **Safe updates**: Preview changes before applying with `chezmoi diff`

### For Power Users

- **Template-driven**: Dynamic configs based on OS, hostname, or custom data
- **Idempotent scripts**: Re-run safely without side effects
- **XDG compliance**: Clean home directory following modern standards
- **Version-controlled**: Track all changes with git

### What's Included

**Development Tools:**
- **mise**: for language version management (Node.js, Python, Rust, Go)
- **Git**: with custom aliases and delta diff viewer
- **Neovim**: with a sensible configuration

**Modern CLI Tools:**
- **eza**: Modern `ls` with colors and icons
- **ripgrep**: Fast code search
- **fd**: Modern `find` replacement
- **bat**: `cat` with syntax highlighting
- **zoxide**: Smart `cd` with frecency
- **fzf**: Fuzzy finder for everything
- **sheldon**: Fast zsh plugin manager
- **git-delta**: Better git diff viewer
- **lazygit**: Terminal UI for git
- **jq** & **yq**: JSON/YAML processor
- **tldr**: Simplified man pages

**Shell Environment:**
- Zsh with numbered, organized configuration files
- Plugin management via Sheldon
- Custom functions and aliases
- Enhanced completions and history

## 🤔 Frequently Asked Questions

**Q: Will this overwrite my existing dotfiles?**
A: No. Chezmoi manages files in `~/.local/share/chezmoi` and symlinks/copies them. Use `chezmoi diff` to preview changes before applying.

**Q: How do I customize configs after installation?**
A: Use `chezmoi edit <file>` to edit in the source directory, then `chezmoi apply` to activate changes.

**Q: Can I use this on multiple machines?**
A: Yes! That's the point. Chezmoi supports machine-specific templates and conditionals.

**Q: How do I uninstall?**
A: Run `chezmoi purge` to remove all managed files, then delete `~/.local/share/chezmoi`.

**Q: Do I need to use all the included tools?**
A: No. Edit `.chezmoidata.yaml` to remove unwanted packages before installation, or use `--skip-packages` flag.

## 📚 Further Reading

- [chezmoi Documentation](https://www.chezmoi.io/) - Official chezmoi docs
- [mise Documentation](https://mise.jdx.dev/) - Language version management
- [Sheldon Documentation](https://sheldon.cli.rs/) - Zsh plugin manager

## 📄 License

MIT License - Personal dotfiles repository. Feel free to fork, modify, and adapt for your own use.

---

**Questions or Issues?** Open an issue at [github.com/adamNewell/dotfiles](https://github.com/adamNewell/dotfiles/issues)
