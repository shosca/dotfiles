local lsp = require('lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active('terraformls') then
  lspconfig.terraformls.setup {
    on_attach = lsp.common_on_attach,
    filetypes = {'tf', 'terraform', 'hcl'}
  }

  vim.cmd [[LspStart]]
end
