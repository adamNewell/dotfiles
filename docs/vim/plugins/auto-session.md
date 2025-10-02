# Auto Session

> Source: [rmagatti/auto-session](https://github.com/rmagatti/auto-session)

A plugin that automatically manages sessions in Neovim, allowing you to seamlessly restore your workspace state.

## Features

- Automatic session saving
- Session restoration by directory
- Custom hooks for save/restore events
- Integration with other plugins
- Configurable auto-save frequency
- Support for multiple sessions
- Session management commands

## Commands

- `:SessionSave` - Manually save the current session
- `:SessionRestore` - Restore the last session for the current directory
- `:SessionDelete` - Delete the current session
- `:Autosession search` - Search through available sessions

## Key Bindings

- `<leader>wr` - Restore session for current directory

## Session Management

The plugin automatically:
1. Saves your session when leaving Neovim
2. Restores your session when entering a directory
3. Maintains separate sessions for different projects
4. Preserves window layouts and buffers

## What Gets Saved

- Open buffers
- Window layout
- Working directory
- Buffer-local options
- Window-local options
- Tab pages
- Terminal buffers (configurable)

## Tips

1. Sessions are saved per directory, perfect for project management
2. Use manual save before major changes
3. Can be configured to auto-save more frequently
4. Integrates well with other plugins like nvim-tree
5. Helps maintain workflow continuity between sessions
