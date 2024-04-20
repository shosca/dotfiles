local utils = require("sh.utils")

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
      { "folke/neodev.nvim", opts = {} },
    },
    -- opts = {
    --   inlay_hints = {
    --     enabled = true,
    --   }
    -- }
  },

  {
    "simrat39/inlay-hints.nvim",
    config = function()
      require("inlay-hints").setup({})
      utils.lsp_attach(function(client, bufnr)
        if client.server_capabilities.inlayHintProvider and bufnr then
          vim.lsp.inlay_hint.enable(bufnr, true)
          require("inlay-hints").on_attach(client, bufnr)
        end
      end)
    end,
    keys = {
      {
        "<Leader>ii",
        function()
          vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
        end,
        desc = "Toggle inlay hints",
      },
    },
  },
}
