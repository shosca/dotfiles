local utils = require("sh.utils")

return {
  "simrat39/inlay-hints.nvim",
  config = function()
    local hints = require("inlay-hints")
    hints.setup({})
    utils.lsp_attach(function(client, bufnr)
      if client.server_capabilities.inlayHintProvider then
        hints.on_attach(client, bufnr)
      end
    end)
  end,
}
