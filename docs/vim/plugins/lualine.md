# Lualine

> Source: `dot_config/nvim/lua/adamNewell/plugins/lualine.lua`

This configuration uses [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) to provide a statusline.

## Configuration

The plugin is configured to use the `base16` theme and to show the number of pending lazy updates.

```lua
return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local lualine = require('lualine')
      local lazy_status = require('lazy.status') -- to configure lazy pending updates count
      local base16 = require('lualine.themes.base16')
      lualine.setup({
      options = {
        theme = base16,
      },
      sections = {
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
    })
    end,
}
```
