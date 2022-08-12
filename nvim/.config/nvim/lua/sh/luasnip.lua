local M = {}

function M.configure_packer(use)
  use({
    "L3MON4D3/LuaSnip",
    requires = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require("luasnip")
      ls.config.set_config({
        enable_autosnippets = true,
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  })
end
return M
