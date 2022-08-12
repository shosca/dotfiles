local lsputil = require("lspconfig/util")

local M = { venvs = {} }

function M.get_python_env(cwd)
  if vim.env.VIRTUAL_ENV then
    return vim.env
  end

  local env = vim.deepcopy(vim.env)
  if cwd == nil then
    cwd = vim.fn.getcwd()
  end
  if M.venvs[cwd] ~= nil then
    env.VIRTUAL_ENV = M.venvs[cwd]
  else
    local poetry_lock = lsputil.path.join(cwd, "poetry.lock")
    local match = vim.fn.glob(poetry_lock, nil, nil)
    if match ~= "" then
      env.VIRTUAL_ENV = vim.fn.trim(vim.fn.system(string.format("cd %s && poetry env info -p", cwd)))
      M.venvs[cwd] = env.VIRTUAL_ENV
    else
      local pipfile = lsputil.path.join(cwd, "Pipfile")
      match = vim.fn.glob(pipfile, nil, nil)
      if match ~= "" then
        env.VIRTUAL_ENV = vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. match .. " pipenv --venv"))
        M.venvs[cwd] = env.VIRTUAL_ENV
      end
    end
  end

  if env.VIRTUAL_ENV ~= nil then
    env.PATH = lsputil.path.join(env.VIRTUAL_ENV, "bin") .. ":" .. env.PATH
  end
  return env
end

return M
