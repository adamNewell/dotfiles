# LSP Configuration

> Source: [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

Configuration for Neovim's built-in Language Server Protocol (LSP) client.

## Features

- Code completion
- Go to definition
- Find references
- Symbol search
- Diagnostics
- Code actions
- Signature help
- Hover documentation

## Installed Language Servers

The following language servers are automatically installed via Mason:

- `html` - HTML language server
- `cssls` - CSS language server
- `tailwindcss` - Tailwind CSS language server
- `svelte` - Svelte language server
- `lua_ls` - Lua language server
- `pyright` - Python language server

## Formatters and Linters

The following tools are installed via Mason:

- `prettier` - Code formatter for web technologies
- `stylua` - Lua formatter
- `isort` - Python import sorter
- `black` - Python formatter
- `pylint` - Python linter
- `eslint_d` - JavaScript/TypeScript linter

## Key Bindings

### Navigation
- `gR` - Show LSP references
- `gD` - Go to declaration
- `gd` - Show LSP definitions
- `gi` - Show LSP implementations
- `gt` - Show LSP type definitions

### Code Actions
- `<leader>ca` - See available code actions
- `<leader>rn` - Smart rename
- `<leader>D` - Show buffer diagnostics
- `<leader>d` - Show line diagnostics
- `[d` - Jump to previous diagnostic
- `]d` - Jump to next diagnostic

### Documentation
- `K` - Show documentation for what is under cursor
- `<leader>rs` - Restart LSP

## Diagnostic Signs

The following diagnostic signs are used in the gutter:

```lua
local signs = {
  Error = " ",
  Warn = " ",
  Hint = "󰠠 ",
  Info = " "
}
```

## Tips

1. Use `K` to quickly view documentation for the symbol under cursor
2. Use `<leader>ca` to see available code actions (like auto-imports, fixes)
3. Use `[d` and `]d` to navigate through diagnostics
4. Use `<leader>rn` for smart renaming across the project
5. LSP servers are automatically installed when you open a relevant file 