# LazyGit

> Source: `dot_config/nvim/lua/adamNewell/plugins/lazygit.lua`

This configuration uses [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) to bring the functionality of the [lazygit](https://github.com/jesseduffield/lazygit) TUI into Neovim.

## Configuration

The plugin is configured to be loaded on command and has a keybinding set to open it.

```lua
return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
  },
}
```

## Keybindings

- `<leader>lg`: Open LazyGit
