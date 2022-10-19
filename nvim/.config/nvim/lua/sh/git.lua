local M = {}

function M.configure_packer(use)
  use({
    "lewis6991/gitsigns.nvim",
    event = { "CursorMoved", "CursorMovedI" },
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr" },
          change = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr" },
          delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr" },
          topdelete = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr" },
          changedelete = { hl = "GitSignsDelete", text = "~", numhl = "GitSignsChangeNr" },
        },
        --numhl = true,
        linehl = false,
        current_line_blame_opts = {
          delay = 2000,
          virt_text_pos = "eol",
        },
      })
    end,
  })
  use("rhysd/committia.vim")
  use("rhysd/conflict-marker.vim")
  use({
    "sindrets/diffview.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup()
    end,
  })
  use({

    "ruifm/gitlinker.nvim",
    config = function()
      require("gitlinker").setup()
      require("sh.keymap").nmap({
        "<leader>gb",
        function()
          require("gitlinker").get_buf_range_url("n", {
            action_callback = require("gitlinker.actions").open_in_browser,
          })
        end,
        { silent = true },
      })
    end,
  })
end

return M
