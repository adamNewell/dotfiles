# Neovim Configuration Documentation

This documentation covers the Neovim configuration and plugins used in this dotfiles repository.

## Plugin Manager

The configuration uses [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager, which provides lazy-loading capabilities and improved startup time.

## Core Plugins

### Editor Enhancement
- [nvim-tree](plugins/nvim-tree.md) - File explorer
- [telescope](plugins/telescope.md) - Fuzzy finder
- [which-key](plugins/which-key.md) - Key binding helper
- [gitsigns](plugins/gitsigns.md) - Git integration
- [vim-maximizer](plugins/vim-maximizer.md) - Window management
- [nvim-surround](plugins/nvim-surround.md) - Surround text objects
- [substitute](plugins/substitute.md) - Enhanced substitution
- [todo-comments](plugins/todo-comments.md) - TODO comments highlighter

### LSP and Completion
- [mason](plugins/mason.md) - LSP installer
- [nvim-lspconfig](plugins/nvim-lspconfig.md) - LSP configuration
- [nvim-cmp](plugins/nvim-cmp.md) - Completion engine

### Appearance
- [monokai-pro](plugins/monokai-pro.md) - Color scheme
- [alpha-nvim](plugins/alpha-nvim.md) - Dashboard
- [indent-blankline](plugins/indent-blankline.md) - Indentation guides

### Language Support
- [treesitter](plugins/treesitter.md) - Syntax highlighting
- [markdown-preview](plugins/markdown-preview.md) - Markdown preview

### Git Integration
- [lazygit](plugins/lazygit.md) - Git UI
- [gitsigns](plugins/gitsigns.md) - Git decorations

## Key Bindings

The leader key is set to `<Space>`. Common key bindings are organized by category:

### General
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>h` - No highlight search

### Navigation
- `<leader>e` - File explorer
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers

### Git
- `<leader>lg` - Open LazyGit
- `<leader>gs` - Git status
- `<leader>gc` - Git commit

### LSP
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show hover documentation
- `<leader>ca` - Code actions

See individual plugin documentation for detailed key bindings and features. 