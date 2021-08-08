local lsp = require('sh.lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active('cssls') then
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  lspconfig.cssls.setup {cmd = {'css-languageserver', '--stdio'}, on_attach = lsp.common_on_attach, capabilities = lsp.capabilities()}

  vim.cmd [[LspStart]]
end
