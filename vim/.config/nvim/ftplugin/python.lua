local lsp = require('lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active("pyright") then
  lspconfig.pyright.setup {
    cmd = {
      vim.fn.stdpath('data') .. '/lspinstall/python/node_modules/.bin/pyright-langserver',
      '--stdio',
    },
    on_attach = lsp.common_on_attach,
  }
  vim.cmd [[LspStart]]
end

