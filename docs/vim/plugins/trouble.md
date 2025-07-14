# Trouble

> Source: [folke/trouble.nvim](https://github.com/folke/trouble.nvim)

A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing.

## Features

- Pretty list for diagnostics, references, etc.
- Integration with LSP
- Integration with Telescope
- Support for quickfix and location lists
- Auto-preview of diagnostics
- Configurable icons and signs
- Todo comments integration

## Key Bindings

- `<leader>xw` - Toggle workspace diagnostics
- `<leader>xd` - Toggle document diagnostics
- `<leader>xq` - Toggle quickfix list
- `<leader>xl` - Toggle location list
- `<leader>xt` - Toggle TODOs list

## Views

1. Workspace Diagnostics:
   - Shows all diagnostics in the workspace
   - Grouped by file
   - Severity indicators

2. Document Diagnostics:
   - Shows diagnostics for current file
   - Line numbers and context
   - Severity levels

3. Quickfix List:
   - Traditional quickfix items
   - Search results
   - Custom lists

4. Location List:
   - File-specific lists
   - Search results
   - Reference results

## Integration with Todo Comments

- Lists all TODO comments
- Grouped by type (TODO, HACK, WARN, etc.)
- Shows file location and context
- Supports filtering and navigation

## Tips

1. Use workspace diagnostics for project-wide issues
2. Use document diagnostics for focused debugging
3. Quickfix list is great for search results
4. Location list works well with LSP references
5. Todo integration helps track project tasks 