local lsp = require('lsp')
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

if not lsp.is_client_active("jedi_language_server") then
  lspconfig.jedi_language_server.setup {
    cmd_env = get_python_env(),
    on_attach = lsp.common_on_attach,
  }
  vim.cmd [[LspStart]]
end

if not lsp.is_client_active('efm') then
  local cmd_env = get_python_env()
  local python_setup = {}
  local bin_path = ''
  if cmd_env.VIRTUAL_ENV then
    bin_path = util.path.join(cmd_env.VIRTUAL_ENV, 'bin') .. '/'
  end

  local flake8 = {
    LintCommand = bin_path .. 'flake8 --stdin-display-name ${INPUT} -',
    lintStdin = true,
    lintFormats = { '%f:%l:%c: %m' },
  }
  table.insert(python_setup, flake8)

  local mypy = {
    LintCommand = bin_path .. 'mypy --show-column-numbers',
    lintFormats = {
      '%f:%l:%c: %trror: %m',
      '%f:%l:%c: %tarning: %m',
      '%f:%l:%c: %tote: %m',
    }
  }
  table.insert(python_setup, mypy)

  local black = {
    LintCommand = bin_path .. 'black --quiet -',
    lintStdin = true,
  }
  table.insert(python_setup, black)

  lspconfig.efm.setup {
    cmd_env = cmd_env,
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities(),
    init_options = { documentFormatting = true, documentSymbol = true, codeAction = true, hover = true },
    filetypes = { "python" },
    settings = {
      rootMarkers = {
        ".git",
        "poetry.lock",
        "pyproject.toml",
        "Pipfile",
        "requirements.txt",
        "requirements.in",
        "setup.cfg",
        "setup.py",
      },
      languages = {
        python = python_setup
      }
    }
  }
  vim.cmd [[LspStart]]
end

