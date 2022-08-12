local lsputil = require("lspconfig/util")

local M = { venvs = {} }

function M.starts_with(str, start)
  return str:sub(1, #start) == start
end

function M.get_python_env(root)
  if vim.env.VIRTUAL_ENV then
    return vim.env
  end

  local env = vim.deepcopy(vim.env)
  if root == nil then
    root = vim.fn.getcwd()
  end
  if M.venvs[root] ~= nil then
    env.VIRTUAL_ENV = M.venvs[root]
  else
    local venv = nil
    for key, value in pairs(M) do
      if M.starts_with(key, "get_venv_with_") then
        venv = value(root)
        if venv ~= nil then
          break
        end
      end
    end
    if venv ~= nil then
      env.VIRTUAL_ENV = venv
      M.venvs[root] = env.VIRTUAL_ENV
    end
  end
  if env.VIRTUAL_ENV ~= nil then
    env.PATH = lsputil.path.join(env.VIRTUAL_ENV, "bin") .. ":" .. env.PATH
  end
  return env
end

function M.get_venv_with_poetry(root)
  local poetry_lock = lsputil.path.join(root, "poetry.lock")
  local match = vim.fn.glob(poetry_lock, nil, nil)
  if match ~= "" then
    return vim.fn.trim(vim.fn.system(string.format("cd %s && poetry env info -p", root)))
  end
end

function M.get_venv_with_pipfile(root)
  local pipfile = lsputil.path.join(root, "Pipfile")
  local match = vim.fn.glob(pipfile, nil, nil)
  if match ~= "" then
    return vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. match .. " pipenv --venv"))
  end
end

return M
