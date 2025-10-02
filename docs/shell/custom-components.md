# Zsh Custom Components

Documentation for custom components and Oh My Zsh integration in the Zsh configuration.

## Custom Functions

> Source: `.config/zsh/functions/`

Directory containing custom Zsh functions for extended functionality.

### Organization

1. Function Types:
   - Utility functions
   - Git helpers
   - Project management
   - System operations

2. File Structure:
   ```
   functions/
   ├── git/           # Git-related functions
   ├── project/       # Project management
   ├── system/        # System operations
   └── utils/         # Utility functions
   ```

### Usage Examples

1. Git Functions:
   ```zsh
   # Create and switch to new branch
   function gnb() {
     git checkout -b "$1"
   }

   # Clean merged branches
   function gcm() {
     git branch --merged | grep -v "\*" | xargs -n 1 git branch -d
   }
   ```

2. Project Functions:
   ```zsh
   # Create new project directory
   function mkproject() {
     mkdir -p "$1" && cd "$1"
   }

   # Initialize development environment
   function devinit() {
     pyenv local 3.10.0
     python -m venv .venv
     source .venv/bin/activate
   }
   ```

## Custom Completions

> Source: `.config/zsh/completions/`

Custom completion definitions for commands and functions.

### Organization

1. Completion Types:
   - Command completions
   - Function completions
   - Tool-specific completions
   - Custom completions

2. File Structure:
   ```
   completions/
   ├── _git          # Git completions
   ├── _docker       # Docker completions
   ├── _custom       # Custom command completions
   └── _project      # Project-related completions
   ```

### Examples

1. Command Completion:
   ```zsh
   #compdef example-command

   _example-command() {
     local -a commands
     commands=(
       'start:Start the service'
       'stop:Stop the service'
       'restart:Restart the service'
     )
     _describe 'command' commands
   }
   ```

2. Function Completion:
   ```zsh
   #compdef mkproject

   _mkproject() {
     _arguments \
       '-t[template]:template:(python node rust)' \
       '-n[name]:project name:'
   }
   ```

## Oh My Zsh Integration

> Source: `.config/zsh/ohmyzsh/`

Oh My Zsh framework integration and customization.

### Configuration

1. Theme Setup:
   ```zsh
   # Theme configuration
   ZSH_THEME="robbyrussell"
   CASE_SENSITIVE="true"
   HYPHEN_INSENSITIVE="true"
   ```

2. Plugin Management:
   ```zsh
   # Plugin configuration
   plugins=(
     git
     docker
     kubectl
     zsh-autosuggestions
     zsh-syntax-highlighting
   )
   ```

### Custom Theme

1. Theme Components:
   ```zsh
   # Custom prompt elements
   PROMPT='${ret_status}%{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}% %{$reset_color%}'
   ```

2. Git Integration:
   ```zsh
   # Git status in prompt
   ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$fg[red]%}"
   ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
   ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
   ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
   ```

## Tips

1. Function Organization:
   - Group related functions
   - Use descriptive names
   - Document usage
   - Include examples

2. Completion Management:
   - Keep completions updated
   - Test with different inputs
   - Document options
   - Handle errors

3. Oh My Zsh:
   - Keep plugins minimal
   - Update regularly
   - Customize thoughtfully
   - Profile performance

4. Maintenance:
   - Review unused functions
   - Update documentation
   - Test completions
   - Monitor load time
