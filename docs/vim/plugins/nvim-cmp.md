# Completion System (nvim-cmp)

> Source: [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

A completion plugin for Neovim coded in Lua.

## Features

- Autocompletion
- LSP integration
- Snippet support
- Buffer words
- Path completion
- VS Code-like pictograms
- Multiple completion sources

## Sources

The following completion sources are configured:

- `cmp-buffer` - Completion from current buffer
- `cmp-path` - Completion for file system paths
- `cmp_luasnip` - Snippet completion
- `friendly-snippets` - Collection of useful snippets
- `lspkind` - VS Code-like pictograms

## Configuration

The completion system is configured to work with LuaSnip for snippets and uses VS Code-style icons.

## Key Bindings

### In Insert Mode
- `<C-Space>` - Trigger completion
- `<C-e>` - Close completion window
- `<CR>` - Confirm completion
- `<Tab>` - Next completion item
- `<S-Tab>` - Previous completion item
- `<C-b>` - Scroll docs backward
- `<C-f>` - Scroll docs forward
- `<C-n>` - Select next item
- `<C-p>` - Select previous item

### In Completion Window
- `<Up>` - Previous item
- `<Down>` - Next item
- `<C-d>` - Scroll docs down
- `<C-u>` - Scroll docs up
- `<Esc>` - Close completion window

## Completion Icons

The following icons are used to indicate different types of completions:

- Text = ""
- Method = "󰆧"
- Function = "󰊕"
- Constructor = ""
- Field = "󰇽"
- Variable = "󰂡"
- Class = "󰠱"
- Interface = ""
- Module = ""
- Property = "󰜢"
- Unit = ""
- Value = "󰎠"
- Enum = ""
- Keyword = "󰌋"
- Snippet = ""
- Color = "󰏘"
- File = "󰈙"
- Reference = ""
- Folder = "󰉋"
- EnumMember = ""
- Constant = "󰏿"
- Struct = ""
- Event = ""
- Operator = "󰆕"
- TypeParameter = "󰅲"

## Tips

1. Use `<Tab>` to navigate through completion items
2. Documentation for the current item is shown automatically
3. Snippets can be expanded using `<Tab>` after selection
4. Path completion works relative to the current file
5. Buffer completion suggests words from all open buffers 