# Nvim Tree

> Source: [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)

A file explorer tree for Neovim written in Lua.

## Features

- File system explorer
- Async file operations
- Git integration
- Diagnostics integration
- Custom filters
- Relative line numbers
- Indent markers

## Configuration

The plugin is configured with the following settings:

```lua
view = {
  width = 35,
  relativenumber = true,
},
renderer = {
  indent_markers = {
    enable = true,
  },
  icons = {
    glyphs = {
      folder = {
        arrow_closed = "", -- arrow when folder is closed
        arrow_open = "", -- arrow when folder is open
      },
    },
  },
},
actions = {
  open_file = {
    window_picker = {
      enable = false,
    },
  },
},
filters = {
  custom = { ".DS_Store" },
},
git = {
  ignore = false,
}
```

## Key Bindings

### Global Mappings

- `<leader>ee` - Toggle file explorer
- `<leader>ef` - Toggle file explorer on current file
- `<leader>ec` - Collapse file explorer
- `<leader>er` - Refresh file explorer

### Within nvim-tree Window

- `<CR>` or `o` - Open file/directory
- `a` - Create new file/directory
- `d` - Delete file/directory
- `r` - Rename file/directory
- `x` - Cut file/directory
- `c` - Copy file/directory
- `p` - Paste file/directory
- `R` - Refresh the tree
- `H` - Toggle hidden files
- `?` - Toggle help
- `<C-]>` - CD into the directory under cursor
- `<BS>` - Close current opened directory or parent
- `.` - Run command with file under cursor
- `<C-v>` - Open file in vertical split
- `<C-x>` - Open file in horizontal split
- `<C-t>` - Open file in new tab
- `<Tab>` - Open file as preview (keeps focus on tree)
- `I` - Toggle git ignored files
- `W` - Collapse all directories

## Tips

1. Use `<leader>ef` to quickly locate current file in the tree
2. Use `I` to toggle visibility of git ignored files
3. Use `.` to run file operations on the selected file
4. Use `<Tab>` for previewing files without leaving the tree 