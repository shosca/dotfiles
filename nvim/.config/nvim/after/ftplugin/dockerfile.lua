local lsp = require("sh.lsp")
local lspconfig = require("lspconfig")

if not lsp.is_client_active("dockerls") then
  lspconfig.dockerls.setup({ on_attach = lsp.common_on_attach, capabilities = lsp.capabilities })
  vim.cmd([[LspStart]])
end
