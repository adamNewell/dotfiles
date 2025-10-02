# Treesitter

> Source: [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

A plugin providing syntax highlighting and code navigation using Treesitter.

## Features

- Advanced syntax highlighting
- Incremental selection
- Indentation
- Auto tag closing
- Syntax-aware code folding

## Installed Parsers

The following language parsers are automatically installed:

```lua
ensure_installed = {
  "awk",
  "bash",
  "bitbake",
  "css",
  "dockerfile",
  "git_config",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "gotmpl",
  "graphql",
  "html",
  "javascript",
  "json",
  "jq",
  "lua",
  "markdown",
  "markdown_inline",
  "mermaid",
  "python",
  "query",
  "regex",
  "ssh_config",
  "svelte",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}
```

## Configuration

```lua
{
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>",
      node_incremental = "<C-space>",
      scope_incremental = false,
      node_decremental = "<bs>",
    },
  },
}
```

## Key Bindings

### Incremental Selection
- `<C-space>` - Start selection / Expand selection
- `<bs>` - Shrink selection

### Code Folding
- `zc` - Close fold
- `zo` - Open fold
- `za` - Toggle fold
- `zR` - Open all folds
- `zM` - Close all folds

## Tips

1. Treesitter provides more accurate syntax highlighting than regex-based highlighting
2. Use incremental selection to quickly select code blocks based on the syntax tree
3. Treesitter parsers are automatically installed when you open a file of that type
4. The indentation feature provides better auto-indent based on syntax
5. Auto-tag feature automatically closes HTML/XML tags
