local utils = require("sh.utils")
local enable = true

return {
  {
    -- https://github.com/pmizio/typescript-tools.nvim
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
    },
    -- opts = {
    --   inlay_hints = {
    --     enabled = true,
    --   }
    -- }
  },
  { "nvim-lua/lsp-status.nvim" },
  {
    "SmiteshP/nvim-navic",
    config = function()
      require("nvim-navic").setup({
        icons = require("sh.ui").kinds,
        highlight = false,
        separator = " > ",
        depth_limit = 0,
        depth_limit_indicator = "..",
        safe_output = true,
      })
      utils.lsp_attach(function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, bufnr)
        end
      end)
    end,
  },
  {
    "simrat39/inlay-hints.nvim",
    config = function()
      require("inlay-hints").setup({})
      utils.lsp_attach(function(client, bufnr)
        if client.server_capabilities.inlayHintProvider and bufnr then
          vim.lsp.inlay_hint.enable(true)
          require("inlay-hints").on_attach(client, bufnr)
        end
      end)
    end,
    keys = {
      {
        "<Leader>ii",
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end,
        desc = "Toggle inlay hints",
      },
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    opts = {},
    keys = {
      {
        "<Leader>dd",
        function()
          enable = not enable
          vim.diagnostic.config({ virtual_lines = enable })
        end,
        desc = "Toggle [d]iagnostics",
      },
    },
  },
}
