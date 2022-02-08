local M = {}

function M.configure_packer(use)
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require"nvim-treesitter.configs".setup {
        ensure_installed = "maintained",
        highlight = {
          enable = true,
          use_languagetree = true,
          disable = {} -- list of language that will be disabled
        },
        rainbow = {enable = true, extended_mode = true},
        incremental_selection = {
          enable = true,
          keymaps = {init_selection = "gnn", node_incremental = "grn", scope_incremental = "grc", node_decremental = "grm"}
        },
        autopairs = {enable = true},
        indent = {enable = true, disable = {"python"}},
        refactor = {
          highlight_definitions = {enable = true},
          highlight_current_scope = {enable = false},
          smart_rename = {enable = true, keymaps = {smart_rename = "grr"}}
        },
        pyfold = {enable = true, custom_foldtext = true},
        endwise = {enable = true}
      }
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    end
  }
  use {"eddiebergman/nvim-treesitter-pyfold"}
  use {"nvim-treesitter/nvim-treesitter-refactor"}
  use {"nvim-treesitter/nvim-treesitter-textobjects"}
  use {"RRethy/nvim-treesitter-endwise"}
end
return M
