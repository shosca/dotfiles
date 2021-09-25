local M = {}
function M.config()
  local ls = require("luasnip")
  ls.config.set_config {history = true, updateevents = "TextChanged,TextChangedI"}
end

function M.configure_packer(use) use {"L3MON4D3/LuaSnip", config = M.config, requires = {"rafamadriz/friendly-snippets"}} end
return M
