local utils = require("sh.utils")

local M = {
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
  keys = {
    {
      "<tab>",
      utils.bind("luasnip", "jumpable", 1),
      expr = true,
      silent = true,
      mode = "i",
    },
    {
      "<tab>",
      utils.bind("luasnip", "jump", 1),
      mode = "s",
    },
    {
      "<s-tab>",
      utils.bind("luasnip", "jump", -1),
      mode = { "i", "s" },
    },
  },
}

return M
