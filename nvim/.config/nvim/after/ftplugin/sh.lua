local lspconfig = require("lspconfig")
local lsp = require("sh.lsp")

if not lsp.is_client_active("bashls") then
  lspconfig.bashls.setup({
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities,
  })
end
