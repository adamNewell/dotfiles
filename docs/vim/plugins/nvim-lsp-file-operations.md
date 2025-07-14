# LSP File Operations

> Source: [antosha417/nvim-lsp-file-operations](https://github.com/antosha417/nvim-lsp-file-operations)

A plugin that adds LSP support for file operations in Neovim, ensuring that LSP servers are notified of file changes.

## Features

- Automatic LSP workspace updates
- File rename synchronization
- File deletion synchronization
- Directory operations support
- Integration with nvim-tree
- Maintains LSP workspace integrity

## Supported Operations

1. File Renames:
   - Updates imports when files are renamed
   - Updates references in workspace
   - Maintains project structure

2. File Deletions:
   - Cleans up references to deleted files
   - Updates workspace state
   - Maintains code integrity

3. Directory Operations:
   - Handles bulk file moves
   - Updates nested references
   - Maintains project structure

## Integration with nvim-tree

The plugin works seamlessly with nvim-tree for:
- File renames through the file explorer
- Directory moves and renames
- File deletions
- Bulk operations

## Benefits

1. Keeps LSP servers in sync with filesystem changes
2. Prevents broken references after file operations
3. Maintains code quality during refactoring
4. Improves project navigation accuracy
5. Reduces manual update requirements

## Tips

1. Use nvim-tree for file operations to ensure LSP sync
2. Let the plugin handle reference updates automatically
3. Works with all LSP rename operations
4. Maintains project integrity during refactoring
5. No manual configuration required 