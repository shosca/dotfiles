local lsp = require('sh.lsp')

if not lsp.is_client_active('jdtls') then
  require('lspconfig').jdtls.setup {
    cmd = {
      'jdtls',
      '--add-modules=ALL-SYSTEM',
      '--add-opens java.base/java.util=ALL-UNNAMED',
      '--add-opens java.base/java.lang=ALL-UNNAMED',
    },
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities()
  }

  vim.cmd [[LspStart]]
end
