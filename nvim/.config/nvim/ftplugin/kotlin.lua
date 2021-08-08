local lsp = require('sh.lsp')

if not lsp.is_client_active('kotlin_language_server') then
  require('lspconfig').kotlin_language_server.setup {on_attach = lsp.on_attach, capabilities = lsp.capabilities()}
end
