local lsp = require("lsp")

if not lsp.is_client_active("rust_analyzer") then
  require("lspconfig").rust_analyzer.setup {
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities(),
  }

  vim.cmd [[LspStart]]
end
