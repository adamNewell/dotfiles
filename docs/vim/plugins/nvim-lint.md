# Nvim Lint

> Source: [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint)

An asynchronous linter plugin for Neovim that supports multiple linters.

## Features

- Asynchronous linting
- Multiple linter support
- Auto-lint on file changes
- Configurable by filetype
- Integration with built-in diagnostics
- Fast and lightweight

## Configured Linters

### JavaScript/TypeScript
- `eslint_d` - Fast JavaScript/TypeScript linter daemon
  - Supports JSX/TSX
  - Supports Svelte

### Python
- `pylint` - Python code analysis tool

## Automatic Linting

The plugin runs linting automatically on:
- Buffer enter
- Buffer write
- Insert leave

## Key Bindings

- `<leader>l` - Trigger manual linting for current file

## Configuration

```lua
linters_by_ft = {
  javascript = { "eslint_d" },
  typescript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  svelte = { "eslint_d" },
  python = { "pylint" },
}
```

## Integration

- Uses Neovim's built-in diagnostics
- Works alongside LSP diagnostics
- Compatible with Trouble.nvim for viewing
- Results appear in the gutter and float windows

## Tips

1. Linting runs asynchronously for better performance
2. Use manual linting when needed with `<leader>l`
3. Linters are installed via Mason
4. View results in diagnostic windows
5. Configure severity levels per linter 