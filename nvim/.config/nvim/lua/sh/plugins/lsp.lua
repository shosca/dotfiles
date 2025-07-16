local utils = require("sh.utils")

return {
  {
    -- https://github.com/neovim/nvim-lspconfig
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        -- https://github.com/folke/lazydev.nvim
        "folke/lazydev.nvim",
        ft = "lua",
        dependencies = {
          {
            -- https://github.com/Bilal2453/luvit-meta
            -- optional `vim.uv` typings
            "Bilal2453/luvit-meta",
            lazy = true,
          },
        },
        opts = {
          library = {
            { path = "luvit-meta/library", words = { "vim%.uv" } },
          },
        },
      },
      {
        -- https://github.com/b0o/SchemaStore.nvim
        "b0o/schemastore.nvim",
      },
    },
  },
  {
    -- https://github.com/nvim-lua/lsp-status.nvim
    "nvim-lua/lsp-status.nvim",
  },
  {
    -- https://github.com/hasansujon786/nvim-navbuddy
    "hasansujon786/nvim-navbuddy",
    lazy = true,
    opts = {
      icons = require("sh.ui").kinds,
      lsp = {
        auto_attach = true,
      },
    },
    keys = {
      {
        "<leader>q",
        utils.bind("nvim-navbuddy", "open"),
      },
    },
  },
  {
    -- https://github.com/SmiteshP/nvim-navic
    "SmiteshP/nvim-navic",
    opts = {
      icons = require("sh.ui").kinds,
      highlight = false,
      separator = " > ",
      depth_limit = 0,
      depth_limit_indicator = "..",
      safe_output = true,
      lsp = {
        auto_attach = true,
      },
    },
  },
  {
    -- https://github.com/rachartier/tiny-inline-diagnostic.nvim
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "modern",
      })
      vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
    end,
  },
}
