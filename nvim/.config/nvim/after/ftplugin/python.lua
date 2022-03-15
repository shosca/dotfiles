local lspconfig = require('lspconfig')
local lsp = require('sh.lsp')
local secrets = require('sh.secrets')

if not lsp.is_client_active("pylsp") then
  local lsputil = require('lspconfig/util')
  local venv = require('sh.utils').get_python_venv()
  local path = vim.env.PATH
  if venv then path = lsputil.path.join(venv, 'bin') .. ':' .. path end
  lspconfig.pylsp.setup {
    cmd = {"pylsp", "-v"},
    cmd_env = {VIRTUAL_ENV = venv, PATH = path},
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities,
    settings = {
      pylsp = {
        plugins = {
          flake8 = {enabled = true},
          jedi_completion = {include_params = true, fuzzy = true},
          pylsp_black = {enabled = true},
          pylsp_mypy = {enabled = true},
          rope_completion = {enabled = false},
          rope_rename = {enabled = true}
        }
      }
    }
  }
  vim.cmd [[LspStart]]
end

if not lsp.is_client_active("sourcery") then
  lspconfig.sourcery.setup {init_options = {token = secrets.sourcery}}
  vim.cmd [[LspStart]]
end

vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 2000)]]
