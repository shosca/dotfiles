local M = {}

function M.configure_packer()
  return {
    {
      "L3MON4D3/LuaSnip",
      requires = { "rafamadriz/friendly-snippets" },
      config = function()
        local ls = require("luasnip")
        ls.config.setup({
          enable_autosnippets = true,
          history = true,
          updateevents = "TextChanged,TextChangedI",
        })
        require("luasnip.loaders.from_vscode").load()
      end,
    },
  }
end

return M
