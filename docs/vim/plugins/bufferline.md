# Bufferline

> Source: `dot_config/nvim/lua/adamNewell/plugins/bufferline.lua`

[bufferline.nvim](https://github.com/akinsho/bufferline.nvim) provides a nice UI for managing buffers.

## Configuration

The plugin is configured to use a "tabs" mode with a "slant" separator style.

```lua
return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "tabs",
      separator_style = "slant",
    },
  },
}
```
