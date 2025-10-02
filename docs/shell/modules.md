# Zsh Modular Components

Documentation for the modular Zsh configuration components that extend the core functionality.

## 01-environment.zsh

- **Source**: `dot_config/zsh/01-environment.zsh`
- **Purpose**: Sets up the core environment, including XDG base directories and other fundamental environment variables.

## 02-path.zsh

- **Source**: `dot_config/zsh/02-path.zsh`
- **Purpose**: Manages the `$PATH` environment variable, adding directories for user binaries, tool-specific paths, and system paths.

## 03-plugins.zsh

- **Source**: `dot_config/zsh/03-plugins.zsh`
- **Purpose**: Loads Zsh plugins using Sheldon.

## 10-completions.zsh

- **Source**: `dot_config/zsh/10-completions.zsh`
- **Purpose**: Configures the shell's autocompletion system.

## 11-history.zsh

- **Source**: `dot_config/zsh/11-history.zsh`
- **Purpose**: Sets up command history.

## 12-options.zsh

- **Source**: `dot_config/zsh/12-options.zsh`
- **Purpose**: Configures shell behavior and features using `setopt`.

## 13-keybindings.zsh

- **Source**: `dot_config/zsh/13-keybindings.zsh`
- **Purpose**: Sets up custom key bindings.

## 20-tools/

- **Source**: `dot_config/zsh/20-tools/`
- **Purpose**: A directory for tool-specific configurations.

## 30-functions/

- **Source**: `dot_config/zsh/30-functions/`
- **Purpose**: A directory for custom shell functions.

## 31-aliases.zsh

- **Source**: `dot_config/zsh/31-aliases.zsh`
- **Purpose**: Contains common command aliases and shortcuts.

## 90-local.zsh

- **Source**: `dot_config/zsh/90-local.zsh`
- **Purpose**: For machine-specific configurations and private settings that are not version-controlled.

## Tips

1. **Organization**:
   - Group related settings in the appropriate files.
   - Use comments to explain complex configurations.

2. **Maintenance**:
   - Review your configuration periodically to remove unused settings.
   - Keep your documentation up-to-date with your configuration.

3. **Security**:
   - Keep sensitive data in `90-local.zsh` and ensure it is not committed to version control.
