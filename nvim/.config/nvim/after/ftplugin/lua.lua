vim.opt_local.shiftwidth = 2

local lsp = require('sh.lsp')

if not lsp.is_client_active('sumneko_lua') then
  local luadev = require('lua-dev').setup({})
  luadev.cmd = { 'lua-language-server' }
  require('lspconfig').sumneko_lua.setup(luadev)
  vim.cmd([[LspStart]])
end

vim.api.nvim_command([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]])
