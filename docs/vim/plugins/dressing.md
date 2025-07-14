# Dressing.nvim

> Source: [stevearc/dressing.nvim](https://github.com/stevearc/dressing.nvim)

A plugin that improves the default Neovim UI elements by providing better looking input and select menus.

## Features

- Enhanced vim.ui.input
  - Floating window input
  - Customizable appearance
  - History support
  - Vim keybindings
  - Relative window positioning

- Enhanced vim.ui.select
  - Telescope integration
  - Built-in fuzzy filtering
  - Preview window support
  - Multi-select capability
  - Custom sorting options

## Integration

1. LSP Features:
   - Rename prompts
   - Code action selection
   - Symbol selection
   - Workspace folder selection

2. Built-in Features:
   - Command line completion
   - Input dialogs
   - Selection menus
   - File browsing

## Benefits

1. Improved User Experience:
   - Modern UI elements
   - Consistent appearance
   - Better readability
   - Familiar interactions

2. Enhanced Functionality:
   - Fuzzy finding
   - History tracking
   - Preview support
   - Customizable behavior

## Configuration

The plugin works out of the box with sensible defaults. Key configuration options:

```lua
require('dressing').setup({
  input = {
    enabled = true,
    default_prompt = "Input:",
    prompt_align = "left",
    insert_only = true,
    border = "rounded",
    relative = "cursor",
  },
  select = {
    enabled = true,
    backend = "telescope",
    trim_prompt = true,
    telescope = {
      layout_config = {
        width = 0.5,
        height = 0.4,
      }
    }
  }
})
```

## Tips

1. Use with LSP for enhanced rename operations
2. Leverage Telescope integration for fuzzy finding
3. Customize appearance to match your colorscheme
4. Take advantage of history features
5. Use relative positioning for better context 