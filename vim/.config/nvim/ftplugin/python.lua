local lsp = require('sh.lsp')
local lspconfig = require('lspconfig')
local util = require('lspconfig/util')

local function get_python_env()
  if vim.env.VIRTUAL_ENV then
    return { VIRTUALENV = vim.env.VIRTUAL_ENV }
  end

  local match = vim.fn.glob(util.path.join(vim.fn.getcwd(), 'Pipfile'))
  if match ~= '' then
    return { VIRTUAL_ENV = vim.fn.trim(vim.fn.system('PIPENV_PIPFILE=' .. match .. ' pipenv --venv')) }
  end

  match = vim.fn.glob(util.path.join(vim.fn.getcwd(), 'poetry.lock'))
  if match ~= '' then
    return { VIRTUAL_ENV = vim.fn.trim(vim.fn.system('poetry env info -p')) }
  end

  return {}
end

if not lsp.is_client_active("pylsp") then
  lspconfig.pylsp.setup {
    cmd_env = get_python_env(),
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities(),
  }
  vim.cmd [[LspStart]]
end

vim.api.nvim_command[[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
