# Conform

> Source: [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)

A formatting engine for Neovim that supports multiple formatters and languages.

## Features

- Format on save
- Multiple formatter support
- LSP formatting fallback
- Async formatting
- Format preview
- Range formatting
- Formatter installation via Mason

## Configured Formatters

### Web Technologies
- `prettier` - JavaScript, TypeScript, JSX, TSX, CSS, HTML, JSON, YAML, Markdown, GraphQL

### Lua
- `stylua` - Lua code formatter

### Python
- `isort` - Python import sorter
- `black` - Python code formatter

## Key Bindings

- `<leader>mp` - Format file or visual selection

## Configuration

```lua
formatters_by_ft = {
  javascript = { "prettier" },
  typescript = { "prettier" },
  javascriptreact = { "prettier" },
  typescriptreact = { "prettier" },
  svelte = { "prettier" },
  css = { "prettier" },
  html = { "prettier" },
  json = { "prettier" },
  yaml = { "prettier" },
  markdown = { "prettier" },
  graphql = { "prettier" },
  lua = { "stylua" },
  python = { "isort", "black" },
}
```

## Format on Save

The plugin is configured to:
- Format on save when possible
- Fall back to LSP formatting if needed
- Timeout after 1000ms
- Run synchronously to ensure completion

## Tips

1. Multiple formatters run in sequence
2. Use range formatting for partial file formatting
3. Formatters are automatically installed via Mason
4. Supports both file and visual selection formatting
5. Integrates with LSP for additional formatting capabilities
