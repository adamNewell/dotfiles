# Linting

> Source: `dot_config/nvim/lua/adamNewell/plugins/linting.lua`

This configuration uses [nvim-lint](https://github.com/mfussenegger/nvim-lint) for linting.

## Configuration

The plugin is configured to use `eslint_d` for web development files and `pylint` for Python. Linting is triggered on buffer enter, write post, and insert leave events.

```lua
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      svelte = { "eslint_d" },
      python = { "pylint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
```

## Keybindings

- `<leader>l`: Trigger linting for the current file.
