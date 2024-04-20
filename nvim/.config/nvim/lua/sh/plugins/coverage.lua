local utils = require("sh.utils")
return {
  "andythigpen/nvim-coverage",
  event = "VimEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    auto_reload = true,
  },
  keys = {
    {
      "<leader>cc",
      utils.bind("coverage", "load", true),
      desc = "[C]overage toggle",
    },
  },
}
