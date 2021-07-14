local lsp = require('lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active('dockerls') then
  lspconfig.dockerls.setup { 
    on_attach = lsp.common_on_attach,
  }
  vim.cmd [[LspStart]]
end
