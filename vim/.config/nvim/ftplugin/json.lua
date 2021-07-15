local lsp = require('lsp')
local lspconfig = require('lspconfig')


if not lsp.is_client_active('jsonls') then
  lspconfig.jsonls.setup {
    cmd = {"vscode-json-languageserver", "--stdio"},
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities(),
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
        end
      }
    }
  }
  vim.cmd [[LspStart]]
end
