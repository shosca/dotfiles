return {
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
}
