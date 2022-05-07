local lsp = require("sh.lsp")
local lspconfig = require("lspconfig")

if not lsp.is_client_active("html") then
  lspconfig.html.setup({
    cmd = { "vscode-html-languageserver", "--stdio" },
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities,
    filetypes = { "html", "htmldjango" },
  })

  vim.cmd([[LspStart]])
end
