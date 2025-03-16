# Telescope

> Source: [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

A highly extendable fuzzy finder over lists. Built on the latest awesome features from Neovim core.

## Features

- Fuzzy finding
- Live preview
- Multiple selection
- History
- Advanced sorting
- File browser
- Git integration
- LSP integration

## Configuration

The plugin is configured with the following settings:

```lua
defaults = {
  path_display = { "smart" },
  mappings = {
    i = {
      ["<C-k>"] = actions.move_selection_previous,
      ["<C-j>"] = actions.move_selection_next,
      ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
    },
  },
}
```

## Key Bindings

### File Navigation
- `<leader>ff` - Find files in current working directory
- `<leader>fr` - Find recently opened files
- `<leader>fs` - Find string in current working directory (live grep)
- `<leader>fc` - Find string under cursor in current working directory
- `<leader>ft` - Find TODOs

### Within Telescope Window
- `<C-k>` - Move to previous item
- `<C-j>` - Move to next item
- `<C-q>` - Send selected items to quickfix list
- `<CR>` - Confirm selection
- `<C-x>` - Go to file selection as a split
- `<C-v>` - Go to file selection as a vsplit
- `<C-t>` - Go to a file in a new tab
- `<C-u>` - Scroll up in preview window
- `<C-d>` - Scroll down in preview window
- `<C-c>` - Close telescope
- `<Esc>` - Close telescope (in normal mode)

### LSP Pickers (when LSP is attached)
- `<leader>gd` - Go to definition
- `<leader>gr` - Find references
- `<leader>gi` - Go to implementation
- `<leader>gt` - Go to type definition

## Tips

1. Use `<C-q>` to send multiple selections to the quickfix list
2. Use `<Tab>` to select multiple items
3. Type `:Telescope` to see all available pickers
4. Use `<C-/>` in the telescope window to see all available key bindings
5. The search is fuzzy by default - you don't need to type the exact string 