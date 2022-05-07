local M = {}

function M.configure_packer(use)
  use({
    "lewis6991/gitsigns.nvim",
    event = { "CursorMoved", "CursorMovedI" },
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "right_align",
          delay = 1000,
        },
      })
    end,
  })
  use("rhysd/committia.vim")
  use("rhysd/conflict-marker.vim")
  use({
    "sindrets/diffview.nvim",
    cmd = "DiffviewOpen",
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
