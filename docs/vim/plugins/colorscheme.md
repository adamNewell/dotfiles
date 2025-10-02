# Colorscheme

> Source: `dot_config/nvim/lua/adamNewell/plugins/colorscheme.lua`

This configuration uses the [monokai-pro.nvim](https://github.com/loctvl842/monokai-pro.nvim) colorscheme.

## Configuration

The plugin is configured to load the `monokai-pro` theme.

```lua
return {
  "loctvl842/monokai-pro.nvim",
  priority = 1000,
  config = function()
    require("monokai-pro").setup()
  end
}
```
