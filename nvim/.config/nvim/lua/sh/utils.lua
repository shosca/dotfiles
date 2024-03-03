local M = { venvs = {} }

function M.require(mod, func)
  local present, module = pcall(require, mod)
  if present and module then
    func(module)
  end
end

function M.bind(mod, func, args)
  local function f()
    require(mod)[func](args)
  end
  return f
end

function M.lsp_attach(func)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      if not (args.data and args.data.client_id) then
        return
      end
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      func(client, bufnr)
    end,
  })
end

function M.path_join(...)
  return table.concat(vim.tbl_flatten({ ... }), "/")
end

function M.starts_with(str, start)
  return str:sub(1, #start) == start
end

function M.get_python_env(args)
  if vim.env.VIRTUAL_ENV then
    return vim.env
  end

  local env = vim.deepcopy(vim.env)
  if args.root == nil then
    args.root = vim.fn.getcwd()
  end
  if M.venvs[args.root] ~= nil then
    env.VIRTUAL_ENV = M.venvs[args.root]
  else
    local venv = nil
    for key, value in pairs(M) do
      if M.starts_with(key, "get_venv_with_") then
        venv = value(args.root)
        if venv ~= nil then
          break
        end
      end
    end
    if venv ~= nil then
      env.VIRTUAL_ENV = venv
      M.venvs[args.root] = env.VIRTUAL_ENV
    end
  end
  if env.VIRTUAL_ENV ~= nil then
    env.PATH = M.path_join(env.VIRTUAL_ENV, "bin") .. ":" .. env.PATH
  end
  return env
end

function M.get_venv_with_poetry(args)
  local poetry_lock = M.path_join(args.root, "poetry.lock")
  if vim.fn.filereadable(poetry_lock) == 1 then
    return vim.fn.trim(vim.fn.system(string.format("cd %s && poetry env info -p", args.root)))
  end
end

function M.get_venv_with_pipfile(args)
  local pipfile = M.path_join(args.root, "Pipfile")
  if vim.fn.filereadable(pipfile) == 1 then
    return vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. pipfile .. " pipenv --venv"))
  end
end

function M.get_venv_with_project_dotvenv_dir(args)
  local venvdir = M.path_join(args.root, ".venv")
  local python = M.path_join(venvdir, "bin", "python")
  if vim.fn.filereadable(python) == 1 then
    return venvdir
  end
end

function M.find_venv_command(args)
  local python_env = M.get_python_env(args)
  if python_env.VIRTUAL_ENV ~= nil then
    local cmdpath = M.path_join(python_env.VIRTUAL_ENV, "bin", args.cmd)
    if vim.fn.filereadable(cmdpath) == 1 then
      return cmdpath
    end
  end
  return args.cmd
end

function M.find_node_command(args)
  if args.root == nil then
    args.root = vim.fn.getcwd()
  end
  return M.path_join(args.root, "node_modules", ".bin", args.cmd)
end

return M
