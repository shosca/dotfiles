local lsputil = require("lspconfig/util")

local M = {}

function M.get_python_env()
  if vim.env.VIRTUAL_ENV then
    return vim.env
  end

  local env = vim.deepcopy(vim.env)
  local cwd = vim.fn.getcwd()

  local poetry_lock = lsputil.path.join(cwd, "poetry.lock")
  local match = vim.fn.glob(poetry_lock, nil, nil)
  if match ~= "" then
    env.VIRTUAL_ENV = vim.fn.trim(vim.fn.system("poetry env info -p"))
  else
    local pipfile = lsputil.path.join(cwd, "Pipfile")
    match = vim.fn.glob(pipfile, nil, nil)
    if match ~= "" then
      env.VIRTUAL_ENV = vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. match .. " pipenv --venv"))
    end
  end

  if env.VIRTUAL_ENV ~= nil then
    env.PATH = lsputil.path.join(env.VIRTUAL_ENV, "bin") .. ":" .. env.PATH
  end
  return env
end

return M
