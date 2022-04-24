local lsp = require('sh.lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active('tsserver') then
  lspconfig.tsserver.setup({
    on_attach = function(client)
      lsp.common_on_attach(client)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end,
    capabilities = lsp.capabilities,
  })

  vim.cmd([[LspStart]])
end
