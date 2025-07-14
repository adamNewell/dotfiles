# Mason

> Source: [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)

A package manager for LSP servers, DAP servers, linters, and formatters.

## Features

- Automatic installation of language servers
- Package management for development tools
- Cross-platform support
- Version management
- Easy configuration
- Visual installation UI

## Installed Language Servers

The following language servers are automatically installed:

- `html` - HTML language server
- `cssls` - CSS language server
- `tailwindcss` - Tailwind CSS language server
- `svelte` - Svelte language server
- `lua_ls` - Lua language server
- `pyright` - Python language server

## Installed Tools

### Formatters
- `prettier` - Code formatter for web technologies
- `stylua` - Lua formatter
- `isort` - Python import sorter
- `black` - Python formatter

### Linters
- `pylint` - Python linter
- `eslint_d` - JavaScript/TypeScript linter

## UI Elements

Mason uses the following icons in its UI:
- ✓ - Package installed
- ➜ - Package pending
- ✗ - Package uninstalled

## Commands

- `:Mason` - Open Mason window
- `:MasonInstall <package>` - Install a package
- `:MasonUninstall <package>` - Uninstall a package
- `:MasonLog` - Open Mason log

## Tips

1. New language servers are installed automatically when needed
2. Use the Mason UI to manage installed packages
3. Check Mason log for installation issues
4. Packages are installed globally for all projects
5. Integrates seamlessly with nvim-lspconfig 