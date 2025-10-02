# Zsh Custom Components

Documentation for custom components in the Zsh configuration.

## Custom Functions

> Source: `dot_config/zsh/30-functions/`

Directory containing custom Zsh functions for extended functionality.

### Organization

Functions are organized into files based on their category, such as `archive.zsh`, `directory.zsh`, `fzf.zsh`, etc.

### Usage Examples

```zsh
# Example from archive.zsh
# Extracts any archive file
ex() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
```

## Custom Completions

> Source: `dot_config/zsh/completions/`

Custom completion definitions for commands and functions.

### Organization

Completion files are named after the command they provide completions for, e.g., `_gwctl`.

## Tips

1. **Function Organization**:
   - Group related functions into the same file.
   - Use descriptive names for files and functions.

2. **Completion Management**:
   - Keep completions updated with the commands they support.

3. **Maintenance**:
   - Review unused functions and completions periodically.
   - Update documentation when adding or changing functions.
