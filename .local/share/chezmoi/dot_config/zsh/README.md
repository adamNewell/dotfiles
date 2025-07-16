# Zsh Configuration Structure

This directory contains a modular zsh configuration that loads in a specific order to ensure proper functionality.

## Loading Order and Numbering Scheme

The configuration files are loaded in numerical order based on their filename prefixes:

### 00-09: Core System Configuration
- **00-environment**: Base environment variables and XDG paths
- **01-options**: Core zsh options and behavior settings
- **02-completion**: Completion system configuration
- **03-history**: History settings and management

### 10-19: Shell Environment
- **10-prompt**: Prompt configuration and themes
- **11-colors**: Color definitions and theming
- **12-keybindings**: Keyboard shortcuts and bindings

### 20-29: Tool Integration
- **20-tools/**: Directory containing tool-specific configurations
  - `misc.zsh`: General command-line tools (zoxide, fzf, bat, etc.)
  - `node.zsh`: Node.js ecosystem tools
  - `python.zsh`: Python environment management
  - `git.zsh`: Git aliases and functions

### 30-39: Custom Functions
- **30-functions/**: Directory containing custom functions organized by purpose
  - `archive.zsh`: Archive/compression utilities
  - `directory.zsh`: Directory navigation helpers
  - `network.zsh`: Network utilities and diagnostics
  - `gwctl.zsh`: Gateway control utilities

### 40-89: Reserved for Future Use
Reserved ranges for additional functionality as the configuration grows.

### 90-99: Finalization
- **90-aliases**: Shell aliases (loaded after tools to override/extend)
- **91-local**: Local machine-specific overrides
- **99-cleanup**: Final cleanup and validation

## Design Principles

1. **Dependency Order**: Lower numbers load first, establishing dependencies for higher numbers
2. **Tool Independence**: Each tool configuration is self-contained and checks for tool availability
3. **Graceful Degradation**: Missing tools don't break the shell initialization
4. **Override Capability**: Higher numbers can override settings from lower numbers

## Adding New Configurations

When adding new configuration files:

1. **Choose appropriate number range** based on dependency requirements
2. **Use descriptive names** after the number prefix
3. **Include availability checks** for external tools
4. **Document any dependencies** in comments

### Examples:
```bash
# Tool integration (20-29 range)
20-tools/docker.zsh         # Docker utilities
21-tools/kubernetes.zsh     # Kubernetes tools

# Custom functions (30-39 range)  
30-functions/text.zsh       # Text manipulation functions
30-functions/development.zsh # Development workflow helpers

# Aliases (90-99 range)
92-git-aliases.zsh          # Git-specific aliases
93-dev-aliases.zsh          # Development aliases
```

## Conditional Loading

All configuration files should include conditional checks:

```bash
# Check if tool is available before configuring
command -v tool_name >/dev/null 2>&1 && {
    # Configuration here
}

# Platform-specific configuration
[[ "$(uname)" == "Darwin" ]] && {
    # macOS-specific settings
}
```

## Debugging

To debug the loading order:
```bash
# Add to any config file to see loading order
echo "Loading: ${(%):-%N}"

# Check what's being sourced
zsh -xvs
```

## Performance Considerations

- Keep tool checks lightweight
- Use command substitution sparingly during initialization
- Defer expensive operations to first use of functions
- Consider using zsh's `autoload` for large functions

---

This structure ensures a reliable, maintainable, and extensible zsh configuration that works across different systems and tool availability scenarios.