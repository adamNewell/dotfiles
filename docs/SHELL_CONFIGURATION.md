# Shell Configuration

This document describes the modern Zsh configuration used in these dotfiles.

## Overview

The shell configuration is built around these principles:
- **Predictable loading order** using numbered prefixes
- **Fast startup times** through optimized plugin loading
- **XDG compliance** for clean file organization
- **Modern tools** like Sheldon for plugin management

## Configuration Structure

### Loading Order

The configuration files are loaded in numerical order to ensure predictable behavior:

```
~/.config/zsh/
├── 01-environment.zsh    # Environment variables and XDG setup
├── 02-path.zsh          # PATH configuration
├── 03-plugins.zsh       # Plugin loading via Sheldon
├── 10-completions.zsh   # Shell completion setup
├── 11-history.zsh       # History configuration
├── 12-options.zsh       # Shell options and behavior
├── 13-keybindings.zsh   # Key bindings and shortcuts
├── 20-tools/            # Tool-specific configurations
│   ├── git.zsh         # Git aliases and functions
│   ├── node.zsh        # Node.js/npm configuration
│   ├── python.zsh      # Python/pip configuration
│   └── rust.zsh        # Rust/cargo configuration
├── 30-functions/        # Custom functions
│   ├── archive.zsh     # Archive extraction functions
│   ├── directory.zsh   # Directory navigation helpers
│   ├── fzf.zsh         # FZF integration
│   └── utility.zsh     # General utility functions
├── 31-aliases.zsh       # Command aliases
└── 90-local.zsh         # Local machine overrides
```

### Layer Descriptions

#### Foundation Layer (01-03)
- **Environment**: Sets up XDG directories and core environment variables
- **PATH**: Configures PATH for various tools and package managers
- **Plugins**: Loads Zsh plugins via Sheldon

#### Initialization Layer (10-13)
- **Completions**: Enables and configures shell completions
- **History**: Sets up command history with sensible defaults
- **Options**: Configures shell behavior and features
- **Keybindings**: Sets up key bindings for navigation and editing

#### Tools Layer (20-29)
- Tool-specific configurations and environment setup
- Language-specific settings (Node.js, Python, Rust, etc.)
- Integration with development tools

#### Interface Layer (30-39)
- Custom functions for enhanced workflow
- Command aliases for frequently used commands
- User interface enhancements

#### Local Layer (90+)
- Machine-specific overrides
- Private configurations not in version control

## Plugin Management with Sheldon

### Why Sheldon?

Sheldon was chosen over other plugin managers for:
- **Performance**: Fast loading and caching
- **Reliability**: Stable, predictable behavior
- **Simplicity**: Clean TOML configuration
- **Maintenance**: Active development and good documentation

### Plugin Configuration

Plugins are defined in `~/.config/sheldon/plugins.toml`:

```toml
shell = "zsh"

[plugins.zsh-completions]
github = "zsh-users/zsh-completions"

[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"
use = ["{{ name }}.zsh"]

[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"

[plugins.oh-my-zsh-lib]
github = "ohmyzsh/ohmyzsh"
dir = "lib"
use = ["git.zsh", "completion.zsh", "key-bindings.zsh"]

[plugins.oh-my-zsh-plugins]
github = "ohmyzsh/ohmyzsh"
dir = "plugins"
use = ["{colored-man-pages,extract,fzf}/*.zsh"]
```

### Managing Plugins

```bash
# Update plugin definitions
chezmoi edit ~/.config/sheldon/plugins.toml

# Rebuild plugin cache after changes
sheldon lock

# Source updated configuration
exec zsh
```

## XDG Base Directory Compliance

The configuration follows XDG Base Directory specifications:

```bash
# XDG directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Tool-specific XDG compliance
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
```

## Key Features

### Smart History

```bash
# History configuration
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$XDG_STATE_HOME/zsh/history"

# History options
setopt EXTENDED_HISTORY      # Record timestamp in history
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first
setopt HIST_IGNORE_DUPS      # Don't record duplicate entries
setopt HIST_IGNORE_SPACE     # Don't record entries starting with space
setopt HIST_VERIFY           # Show command with history expansion
setopt SHARE_HISTORY         # Share history between sessions
```

### Enhanced Completions

```bash
# Enable completions
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Completion options
setopt AUTO_MENU            # Show completion menu on second tab
setopt COMPLETE_IN_WORD     # Complete from both ends of word
setopt ALWAYS_TO_END        # Move cursor to end of word
```

### Tool Integration

#### FZF Integration
- Dynamic downloading and caching of fzf-git.sh
- Custom key bindings for file and command search
- Integration with git operations

#### Git Enhancement
- Comprehensive git aliases
- Git prompt integration
- Branch management helpers

#### Development Tools
- Language version management via mise
- Package manager integration
- Environment setup for Node.js, Python, Rust

## Customization

### Local Overrides

Create `~/.config/zsh/90-local.zsh` for machine-specific configurations:

```bash
# Local aliases
alias work="cd ~/work/projects"

# Local environment variables
export COMPANY_API_KEY="secret"

# Local PATH additions
export PATH="$HOME/local/bin:$PATH"
```

### Adding New Tools

1. **Add tool configuration** in `20-tools/` directory:
   ```bash
   # ~/.config/zsh/20-tools/newtool.zsh
   export NEWTOOL_CONFIG="$XDG_CONFIG_HOME/newtool"
   alias nt="newtool"
   ```

2. **Add to chezmoi** for version control:
   ```bash
   chezmoi add ~/.config/zsh/20-tools/newtool.zsh
   ```

### Adding New Functions

Create functions in `30-functions/` directory:

```bash
# ~/.config/zsh/30-functions/myfunction.zsh
myfunction() {
    local arg1="$1"
    echo "Processing: $arg1"
    # Function implementation
}
```

## Performance Optimization

### Lazy Loading

Many tools are configured for lazy loading to improve startup time:

```bash
# Example: Load nvm only when needed
nvm() {
    unfunction nvm
    export NVM_DIR="$XDG_DATA_HOME/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    nvm "$@"
}
```

### Async Operations

Some operations are performed asynchronously:

```bash
# Async fzf-git download
{
    # Download in background
    curl -sSL "$fzf_git_url" > "$fzf_git_cache.new"
    mv "$fzf_git_cache.new" "$fzf_git_cache"
} &!
```

## Troubleshooting

### Common Issues

1. **Slow startup**: Check plugin loading times with `zsh -xvs`
2. **Missing completions**: Rebuild completion cache with `rm ~/.cache/zsh/zcompdump*; exec zsh`
3. **Plugin issues**: Rebuild sheldon cache with `sheldon lock`

### Debug Mode

Enable debug output for troubleshooting:

```bash
# Add to ~/.config/zsh/90-local.zsh
export ZDEBUG=1
exec zsh
```

### Plugin Management

```bash
# List installed plugins
sheldon list

# Update all plugins
sheldon update

# Add new plugin
chezmoi edit ~/.config/sheldon/plugins.toml
sheldon lock
```

## Best Practices

1. **Keep functions small and focused**
2. **Use XDG directories for all tool configurations**
3. **Test changes in a separate shell before committing**
4. **Document custom functions and aliases**
5. **Use lazy loading for heavy tools**
6. **Prefer shell built-ins over external commands when possible**

This configuration provides a solid foundation for a productive shell environment while remaining maintainable and extensible.
