vim.opt_local.autoindent = true
vim.opt_local.cindent = true
vim.opt_local.copyindent = true
vim.opt_local.expandtab = true
vim.opt_local.smartindent = true
vim.opt_local.shiftwidth = 4
vim.opt_local.smarttab = true
vim.opt_local.softtabstop = 4
vim.opt_local.tabstop = 8

local null_ls = require("null-ls")

local register = function(typ, name, cmd)
  if not null_ls.is_registered({ name = name }) then
    if cmd ~= nil then
      cmd = name
    end
    null_ls.register(null_ls.builtins[typ][name].with({
      cmd = cmd,
      env = require("sh.utils").get_python_env(),
    }))
  end
end
register("diagnostics", "flake8", "flake8heavened")
-- register("diagnostics", "mypy")
register("formatting", "black")

-- local dap = require("dap")
-- local dapcmd = "python"
-- if python_env.VIRTUAL_ENV then
--   dapcmd = lsputil.path.join(python_env.VIRTUAL_ENV, "bin", "python")
-- end
--
-- dap.adapters.python = { type = "executable", command = dapcmd, args = { "-m", "debugpy.adapter" } }
-- require("dap.ext.vscode").load_launchjs()
