local lsp = require("lsp")

if not lsp.is_client_active("gopls") then
  require("lspconfig").gopls.setup {
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities(),
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
    },
    settings = {
      gopls = {
        analyses = {
          unusedparams = true
        },
        staticcheck = true
      }
    },
  }

  vim.cmd [[LspStart]]
end
