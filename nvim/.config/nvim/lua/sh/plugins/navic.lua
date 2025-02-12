return {
  "SmiteshP/nvim-navic",
  config = function()
    require("nvim-navic").setup {
      icons = require("sh.ui").kinds,
      highlight = false,
      separator = " > ",
      depth_limit = 0,
      depth_limit_indicator = "..",
      safe_output = true,
    }
    require("sh.utils").lsp_attach(function(client, bufnr)
      if client.server_capabilities.documentSymbolProvider then
        require("nvim-navic").attach(client, bufnr)
      end
    end)
  end,
}
