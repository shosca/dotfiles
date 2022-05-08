local lsputil = require("lspconfig/util")

local M = {}

function M.get_python_env()
  if vim.env.VIRTUAL_ENV then
    return vim.env
  end

  local env = vim.deepcopy(vim.env)
  local cwd = vim.fn.getcwd()
  local pipfile = lsputil.path.join(cwd, "Pipfile")
  local match = vim.fn.glob(pipfile, nil, nil)
  if match ~= "" then
    env.VIRTUAL_ENV = vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. match .. " pipenv --venv"))
  end

  local pyproject = lsputil.path.join(cwd, "poetry.lock")
  match = vim.fn.glob(pyproject, nil, nil)
  if match ~= "" then
    env.VIRTUAL_ENV = vim.fn.trim(vim.fn.system("poetry env info -p"))
  end

  env.PATH = lsputil.path.join(env.VIRTUAL_ENV, "bin") .. ":" .. env.PATH
  return env
end

return M
