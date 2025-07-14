# Gitsigns

> Source: [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)

A plugin for showing git changes in the sign column and providing git operations.

Git integration in Neovim is handled through multiple plugins:

1. `gitsigns.nvim` - Shows git status in the sign column
2. `lazygit.nvim` - Full git UI inside Neovim

## Gitsigns Features

- Line status in sign column (added, removed, changed)
- Preview git changes
- Stage/unstage hunks
- Undo stage hunk
- Reset hunks
- Blame line
- Live blame
- Toggle signs
- Toggle line blame
- Toggle deleted

## Key Bindings

### Navigation
- `]h` - Next hunk
- `[h` - Previous hunk

### Actions
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hS` - Stage buffer
- `<leader>hR` - Reset buffer
- `<leader>hu` - Undo stage hunk
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame line with full message
- `<leader>hB` - Toggle current line blame
- `<leader>hd` - Diff this file
- `<leader>hD` - Diff against specific commit

### Visual Mode
- `<leader>hs` - Stage selected lines
- `<leader>hr` - Reset selected lines

### Text Objects
- `ih` - Select hunk text object

## LazyGit Integration

LazyGit provides a full terminal UI for Git operations.

### Key Bindings
- `<leader>lg` - Open LazyGit interface

### LazyGit Features
- View status, log, and diffs
- Stage/unstage files
- Commit changes
- Push/pull
- Branch management
- Resolve merge conflicts
- Interactive rebase
- Stash management

## Tips

1. Use `<leader>hb` to see who last modified a line
2. Use `<leader>hp` to preview changes before staging
3. Use `ih` text object with operations like `dih` (delete hunk) or `vih` (select hunk)
4. LazyGit provides a more comprehensive interface for complex git operations
5. Use `<leader>hB` to toggle inline blame for the current file 