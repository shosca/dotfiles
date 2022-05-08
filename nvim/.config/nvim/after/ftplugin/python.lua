local lspconfig = require("lspconfig")
local lsputil = require("lspconfig/util")
local dap = require("dap")
local lsp = require("sh.lsp")
local secrets = require("sh.secrets")

local python_env = require("sh.utils").get_python_env()

if not lsp.is_client_active("pylsp") then
  lspconfig.pylsp.setup({
    cmd = { "pylsp" },
    cmd_env = python_env,
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities,
    settings = {
      pylsp = {
        plugins = {
          flake8 = { enabled = true },
          jedi_completion = { include_params = true, fuzzy = true },
          pylsp_black = { enabled = true },
          pylsp_mypy = { enabled = true },
          rope_completion = { enabled = false },
          rope_rename = { enabled = true },
        },
      },
    },
  })
  vim.cmd([[LspStart]])
end

if not lsp.is_client_active("sourcery") then
  lspconfig.sourcery.setup({ init_options = { token = secrets.sourcery.token } })
  vim.cmd([[LspStart]])
end

local dapcmd = "python"
if python_env.VIRTUAL_ENV then
  dapcmd = lsputil.path.join(python_env.VIRTUAL_ENV, "bin", "python")
end

dap.adapters.python = { type = "executable", command = dapcmd, args = { "-m", "debugpy.adapter" } }
require("dap.ext.vscode").load_launchjs()
