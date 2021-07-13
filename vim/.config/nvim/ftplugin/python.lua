local lsp = require('lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active("jedi_language_server") then
  lspconfig.jedi_language_server.setup {
    on_attach = lsp.common_on_attach,
  }
  vim.cmd [[LspStart]]
end

if not lsp.is_client_active('efm') then
  lspconfig.efm.setup {
    on_attach = lsp.common_on_attach,
  }
  vim.cmd [[LspStart]]
end

