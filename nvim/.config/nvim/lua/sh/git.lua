local M = {}

function M.configure_packer(use)
  use {"lewis6991/gitsigns.nvim", requires = {"nvim-lua/plenary.nvim"}, config = function() require("gitsigns").setup {current_line_blame = true} end}
  use "rhysd/committia.vim"
  use "sindrets/diffview.nvim"
  use {
    "ruifm/gitlinker.nvim",
    config = function()
      require('gitlinker').setup()
      vim.api.nvim_set_keymap('n', '<leader>gb',
                              '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
                              {silent = true})
    end
  }
  if vim.fn.executable "gh" == 1 then use "pwntester/octo.nvim" end
end
return M
