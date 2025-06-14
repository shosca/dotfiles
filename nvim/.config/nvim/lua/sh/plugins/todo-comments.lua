local utils = require "sh.utils"

return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = { "BufReadPost", "BufNewFile" },
  config = true,
  keys = {
    {
      "]t",
      utils.bind("todo-comments", "jump_next"),
      desc = "Next todo comment",
    },
    {
      "[t",
      utils.bind("todo-comments", "jump_prev"),
      desc = "Previous todo comment",
    },
    { "<leader>td", "<cmd>TodoTelescope<cr>", desc = "Todo" },
    { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
  },
}
