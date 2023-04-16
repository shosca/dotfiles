local utils = require("sh.utils")

return {
  "simrat39/inlay-hints.nvim",
  config = function()
    local hints = require("inlay-hints")
    hints.setup({})
    utils.lsp_attach(hints.on_attach)
  end,
}
