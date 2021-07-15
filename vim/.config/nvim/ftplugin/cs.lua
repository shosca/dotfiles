local lsp = require("lsp")
local lspconfig = require("lspconfig")

if not lsp.is_client_active("omnisharp") then
  lspconfig.omnisharp.setup {
    cmd = { "omnisharp", "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) },
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities(),
  }

  vim.cmd [[LspStart]]
end
