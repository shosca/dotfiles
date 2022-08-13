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
  if vim.fn.filereadable(poetry_lock) then
    vim.notify("found " .. poetry_lock)
    return vim.fn.trim(vim.fn.system(string.format("cd %s && poetry env info -p", root)))
  end
end

function M.get_venv_with_pipfile(root)
  local pipfile = lsputil.path.join(root, "Pipfile")
  if vim.fn.filereadable(pipfile) then
    vim.notify("found " .. pipfile)
    return vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. pipfile .. " pipenv --venv"))
  end
end

function M.get_venv_with_project_dotvenv_dir(root)
  local venvdir = lsputil.path.join(root, ".venv", "bin")
  local python = lsputil.path.join(venvdir, "python")
  if vim.fn.filereadable(python) then
    vim.notify("found " .. python)
    return venvdir
  end
end

function M.find_venv_command(root, cmd)
  local python_env = require("sh.utils").get_python_env(root)
  if python_env.VIRTUAL_ENV ~= nil then
    local cmdpath = lsputil.path.join(python_env.VIRTUAL_ENV, "bin", cmd)
    if vim.fn.filereadable(cmdpath) then
      return cmdpath
    end
  end
  return cmd
end

return M
