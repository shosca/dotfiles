local lsp = require('lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active('yamlls') then
  lspconfig.yamlls.setup {
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities(),
  }

  vim.cmd [[LspStart]]
end
