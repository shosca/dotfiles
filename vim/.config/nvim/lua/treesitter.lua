return {
  configure_packer = function(use)
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = function()
        require "nvim-treesitter.configs".setup {
          ensure_installed = "maintained",
          highlight = {
            enable = true,
            disable = {  },  -- list of language that will be disabled
          },
          rainbow = {
            enable = true,
            extended_mode = true,
          },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "gnn",
              node_incremental = "grn",
              scope_incremental = "grc",
              node_decremental = "grm",
            },
          },
          indent = {
            enable = true,
          }
        }
        vim.opt.foldmethod = 'expr'
        vim.opt.foldexpr='nvim_treesitter#foldexpr()'
      end
    }
  end
}
