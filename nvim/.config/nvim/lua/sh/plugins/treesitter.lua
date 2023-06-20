local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  {
    "yioneko/nvim-yati",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        yati = {
          enable = true,
          default_lazy = true,
        },
        highlight = {
          enable = true,
          use_languagetree = true,
          disable = { "" }, -- list of language that will be disabled
        },
        rainbow = { enable = true, extended_mode = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        autopairs = { enable = true },
        indent = { enable = false }, --, disable = { "python" } },
        refactor = {
          highlight_definitions = { enable = true },
          highlight_current_scope = { enable = false },
          smart_rename = {
            enable = true,
            keymaps = { smart_rename = "grr" },
          },
        },
        endwise = { enable = true },
      })
    end,
  },
  { "nvim-treesitter/nvim-treesitter-refactor", dependencies = "nvim-treesitter/nvim-treesitter" },
  { "nvim-treesitter/nvim-treesitter-textobjects", dependencies = "nvim-treesitter/nvim-treesitter" },
  { "RRethy/nvim-treesitter-endwise", dependencies = "nvim-treesitter/nvim-treesitter" },
}

return M
