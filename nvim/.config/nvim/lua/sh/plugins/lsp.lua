local utils = require("sh.utils")

return {
  {
    -- https://github.com/nvimtools/none-ls.nvim
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        debounce = 1000,
        sources = {
          null_ls.builtins.diagnostics.mypy,
        },
      })
    end,
  },
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
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            { path = "LazyVim", words = { "LazyVim" } },
            { path = "snacks.nvim", words = { "Snacks" } },
            { path = "lazy.nvim", words = { "LazyVim" } },
            { path = "nvim-lspconfig", words = { "lspconfig.settings" } },
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
    -- https://github.com/rachartier/tiny-inline-diagnostic.nvim
    "rachartier/tiny-inline-diagnostic.nvim",
    --event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "modern",
        options = {
          multilines = {
            enabled = true,
          },
        },
      })
      vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
    end,
  },
}
