local M = {
  { "antoinemadec/FixCursorHold.nvim" },
  { "neovim/nvim-lspconfig" },
  { "folke/neodev.nvim" },
  { "b0o/schemastore.nvim" },
  { "jose-elias-alvarez/null-ls.nvim" },
  { "nvim-lua/lsp-status.nvim" },
  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({})
    end,
  },
  {
    url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
    end,
  },
}

return M
