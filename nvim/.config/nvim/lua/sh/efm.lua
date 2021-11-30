local lspconfig = require('lspconfig')
local lsp = require('sh.lsp')

local M = {}

function M.lua_setup()
  return {
    {
      formatCommand = 'lua-format --tab-width=2 --indent-width 2 --column-limit=150 --align-parameter --chop-down-table --chop-down-kv-table -i',
      formatStdin = true,
      rootMarkers = {".git"}
    }
  }
end

function M.setup()

  lspconfig.efm.setup {
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities,
    init_options = {documentFormatting = true, documentSymbol = true, codeAction = true, hover = true},
    filetypes = {"python", "lua"},
    settings = {languages = {lua = M.lua_setup()}}
  }

end

return M
