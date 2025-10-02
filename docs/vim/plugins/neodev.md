# Neodev

> Source: [folke/neodev.nvim](https://github.com/folke/neodev.nvim)

A plugin that adds support for Neovim Lua API development with full LSP support.

## Features

- Full Neovim Lua API documentation
- Type checking for Neovim API
- Signature help for Neovim functions
- Completion for Vim and Lua APIs
- Plugin development support
- Automatic setup with nvim-lspconfig

## Functionality

1. LSP Features:
   - Completion for Neovim API
   - Documentation on hover
   - Signature help
   - Go to definition
   - Type checking

2. Development Support:
   - Plugin development helpers
   - Runtime path handling
   - Library type definitions
   - Configuration type checking

## Configuration

The plugin is configured with default settings:
```lua
{
  library = {
    enabled = true,
    runtime = true,
    types = true,
    plugins = true,
  }
}
```

## Benefits

1. Enhanced Lua Development:
   - Better type checking
   - Improved code completion
   - Accurate documentation
   - Faster development

2. Plugin Development:
   - API documentation access
   - Type safety
   - Better error detection
   - Improved maintainability

## Tips

1. Use with nvim-lspconfig for best experience
2. Hover over Vim functions for documentation
3. Get type checking for your plugin code
4. Access full Neovim API documentation
5. Improves plugin development workflow
