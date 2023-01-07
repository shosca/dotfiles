local lspconfig = require("lspconfig")
local lsp = require("sh.lsp")
local ui = require("sh.ui")
local secrets = require("sh.secrets")
local lspstatus = require("lsp-status")
local json_schemas = require("schemastore").json.schemas({})
local yaml_schemas = {}
vim.tbl_map(function(schema)
  yaml_schemas[schema.url] = schema.fileMatch
end, json_schemas)

require("neodev").setup({
  library = { plugins = { "neotest" }, types = true },
})

vim.lsp.handlers["textDocument/definition"] = function(_, result)
  if not result or vim.tbl_isempty(result) then
    print("[LSP] Could not find definition")
    return
  end

  if vim.tbl_islist(result) then
    vim.lsp.util.jump_to_location(result[1], "utf-8", true)
  else
    vim.lsp.util.jump_to_location(result, "utf-8", true)
  end
end
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = ui.borders })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = ui.borders })

local servers = {
  sumneko_lua = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },
  eslint = {},
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--suggest-missing-includes",
      "--clang-tidy",
      "--header-insertion=iwyu",
    },
    -- Required for lsp-status
    init_options = {
      clangdFileStatus = true,
    },
    handlers = lspstatus.extensions.clangd.setup(),
    capabilities = vim.tbl_deep_extend("force", vim.deepcopy(lsp.capabilities), { offsetEncoding = { "utf-16" } }),
  },
  jedi_language_server = {
    on_new_config = function(new_config, root)
      local u = require("sh.utils")
      new_config.cmd_env = u.get_python_env(root)
      return true
    end,
  },
  -- pylsp = {
  --   on_new_config = function(new_config, root)
  --     local u = require("sh.utils")
  --     new_config.cmd = {
  --       u.find_venv_command(root, "pylsp"),
  --       "-v",
  --       "--log-file",
  --       vim.fn.stdpath("state") .. "/pylsp.log",
  --     }
  --     new_config.cmd_env = u.get_python_env(root)
  --     return true
  --   end,
  --   settings = {
  --     pylsp = {
  --       plugins = {
  --         flake8 = { enabled = false },
  --         mccabe = { enabled = false },
  --         pyflakes = { enabled = false },
  --         pycodestyle = { enabled = false },
  --         jedi_completion = { include_params = true, fuzzy = true },
  --         pylsp_black = { enabled = false },
  --         pylsp_mypy = { enabled = false, dmypy = true },
  --         rope_completion = { enabled = true },
  --         rope_rename = { enabled = true },
  --       },
  --     },
  --   },
  -- },
  sourcery = {
    on_new_config = function(new_config, root)
      require("lspconfig.server_configurations.sourcery").default_config.on_new_config(new_config, root)
      new_config.cmd_env = require("sh.utils").get_python_env(root)
    end,
    init_options = { token = secrets.sourcery.token },
  },
  solargraph = {
    cmd = { "bundle", "exec", "solargraph", "stdio" },
  },
  sorbet = {
    cmd = { "bundle", "exec", "srb", "tc", "--lsp", "--disable-watchman" },
    on_new_config = function(new_config, root)
      table.insert(new_config.cmd, root)
      return true
    end,
  },
  rust_analyzer = {},
  gopls = {
    init_options = { usePlaceholders = true, completeUnimported = true },
    settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } },
  },
  crystalline = {},
  omnisharp = {
    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  },
  cssls = {
    cmd = { "vscode-css-languageserver", "--stdio" },
  },
  dockerls = {},
  terraformls = {
    filetypes = { "tf", "terraform", "hcl" },
  },
  html = {
    cmd = { "vscode-html-languageserver", "--stdio" },
    filetypes = { "html", "htmldjango" },
  },
  jdtls = {
    cmd = {
      "jdtls",
      "--add-modules=ALL-SYSTEM",
      "--add-opens java.base/java.util=ALL-UNNAMED",
      "--add-opens java.base/java.lang=ALL-UNNAMED",
    },
  },
  kotlin_language_server = {},
  tsserver = {},
  jsonls = {
    cmd = { "vscode-json-languageserver", "--stdio" },
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
        end,
      },
    },
    settings = {
      json = {
        format = { enable = true },
        schemas = json_schemas,
        validate = { enable = true },
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        hover = true,
        completion = true,
        validate = true,
        customTags = {
          "!Base64",
          "!Cidr",
          "!FindInMap sequence",
          "!GetAtt",
          "!GetAZs",
          "!ImportValue",
          "!Join sequence",
          "!Ref",
          "!Select sequence",
          "!Split sequence",
          "!Sub sequence",
          "!Sub",
          "!And sequence",
          "!Condition",
          "!Equals sequence",
          "!If sequence",
          "!Not sequence",
          "!Or sequence",
        },
        editor = { formatOnType = true },
        schemas = yaml_schemas,
      },
    },
  },
  bashls = {},
}

for server, opts in pairs(servers) do
  if opts.on_attach == nil then
    opts.on_attach = lsp.common_on_attach
  end
  if opts.capabilities == nil then
    opts.capabilities = lsp.capabilities
  end
  lspconfig[server].setup(opts)
end

local nullls = require("null-ls")
nullls.setup({
  on_attach = lsp.common_on_attach,
  debounce = 600,
  sources = {
    nullls.builtins.code_actions.gitrebase,
    nullls.builtins.code_actions.gitsigns,

    nullls.builtins.formatting.shfmt.with({
      extra_args = {
        "-i",
        "4", -- 4 spaces
        "-ci", -- indent switch cases
        "-sr", -- redirect operators are followed by space
        "-bn", -- binary ops like && or | (pipe) start the line
      },
    }),

    nullls.builtins.formatting.black.with({
      dynamic_command = function(params)
        return require("sh.utils").find_venv_command(params.root, params.command)
      end,
    }),
    nullls.builtins.diagnostics.flake8.with({
      dynamic_command = function(params)
        return require("sh.utils").find_venv_command(params.root, params.command)
      end,
    }),

    nullls.builtins.formatting.terraform_fmt.with({
      filetypes = { "hcl", "terraform" },
    }),
  },
})
