return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-refactor",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "RRethy/nvim-treesitter-endwise",
  },
  build = ":TSUpdate",
  cmd = { "TSUpdateSync" },
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    rainbow = { enable = true, extended_mode = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
    autopairs = { enable = true },
    refactor = {
      highlight_definitions = { enable = true },
      highlight_current_scope = { enable = false },
      smart_rename = {
        enable = true,
        keymaps = { smart_rename = "grr" },
      },
    },
    endwise = { enable = true },
  },
}
