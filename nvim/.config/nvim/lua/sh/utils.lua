local M = { venvs = {} }

function M.require(mod, func)
  local present, module = pcall(require, mod)
  if present and module then
    func(mod)
  end
end

function M.path_join(...)
  return table.concat(vim.tbl_flatten({ ... }), "/")
end

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
    env.PATH = M.path_join(env.VIRTUAL_ENV, "bin") .. ":" .. env.PATH
  end
  return env
end

function M.get_venv_with_poetry(root)
  local poetry_lock = M.path_join(root, "poetry.lock")
  if vim.fn.filereadable(poetry_lock) == 1 then
    vim.defer_fn(function()
      vim.notify("found " .. poetry_lock)
    end, 1000)
    return vim.fn.trim(vim.fn.system(string.format("cd %s && poetry env info -p", root)))
  end
end

function M.get_venv_with_pipfile(root)
  local pipfile = M.path_join(root, "Pipfile")
  if vim.fn.filereadable(pipfile) == 1 then
    vim.defer_fn(function()
      vim.notify("found " .. pipfile)
    end, 1000)
    return vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. pipfile .. " pipenv --venv"))
  end
end

function M.get_venv_with_project_dotvenv_dir(root)
  local venvdir = M.path_join(root, ".venv")
  local python = M.path_join(venvdir, "bin", "python")
  if vim.fn.filereadable(python) == 1 then
    vim.defer_fn(function()
      vim.notify("found " .. python)
    end, 1000)
    return venvdir
  end
end

function M.find_venv_command(root, cmd)
  local python_env = require("sh.utils").get_python_env(root)
  if python_env.VIRTUAL_ENV ~= nil then
    local cmdpath = M.path_join(python_env.VIRTUAL_ENV, "bin", cmd)
    if vim.fn.filereadable(cmdpath) == 1 then
      return cmdpath
    end
  end
  return cmd
end

return M
