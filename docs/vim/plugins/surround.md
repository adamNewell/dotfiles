# Surround

> Source: `dot_config/nvim/lua/adamNewell/plugins/surround.lua`

This configuration uses [nvim-surround](https://github.com/kylechui/nvim-surround) to add, change, and delete surroundings in pairs.

## Configuration

The plugin is simply enabled with default settings.

```lua
return {
  "kylechui/nvim-surround",
  event = { "BufReadPre", "BufNewFile" },
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  config = true,
}
```
