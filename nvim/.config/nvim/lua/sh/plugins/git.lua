local M = {
  {
    "lewis6991/gitsigns.nvim",
    event = { "CursorMoved", "CursorMovedI" },
    dependencies = { "nvim-lua/plenary.nvim" },
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
  },
  { "rhysd/committia.vim" },
  { "rhysd/conflict-marker.vim" },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup()
    end,
  },
  {

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
  },
}

return M
