local lspconfig = require('lspconfig')
local lsp = require('sh.lsp')

if not lsp.is_client_active("crystalline") then
  lspconfig.crystalline.setup {on_attach = lsp.common_on_attach, capabilities = lsp.capabilities}
  vim.cmd [[LspStart]]
end
