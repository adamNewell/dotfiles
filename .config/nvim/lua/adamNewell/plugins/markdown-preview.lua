return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,

  keys = {
    { "<leader>md", "<cmd>MarkdownPreview<CR>", desc = "Open interactive Markdown session in browser" },
  },
}
