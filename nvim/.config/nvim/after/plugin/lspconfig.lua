local lspconfig = require("lspconfig")
local secrets = require("sh.secrets")
local lspstatus = require("lsp-status")
local json_schemas = require("schemastore").json.schemas({})
local yaml_schemas = {}
vim.tbl_map(function(schema)
  yaml_schemas[schema.url] = schema.fileMatch
end, json_schemas)

local caps = vim.lsp.protocol.make_client_capabilities()
caps.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
caps.textDocument.completion.completionItem.snippetSupport = true
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  caps = cmp_nvim_lsp.default_capabilities(caps)
end

local servers = {
  lua_ls = {
    settings = {
      Lua = {
        hint = {
          enable = true,
        },
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },
  zls = {},
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
    capabilities = vim.tbl_deep_extend("force", vim.deepcopy(caps), { offsetEncoding = { "utf-16" } }),
  },
  -- jedi_language_server = {
  --   on_new_config = function(new_config, root)
  --     local u = require("sh.utils")
  --     new_config.cmd_env = u.get_python_env(root)
  --     return true
  --   end,
  -- },
  pylsp = {
    on_new_config = function(new_config, root)
      local u = require("sh.utils")
      new_config.cmd = {
        u.find_venv_command(root, "pylsp"),
        "-v",
        "--log-file",
        vim.fn.stdpath("state") .. "/pylsp.log",
      }
      new_config.cmd_env = u.get_python_env(root)
      return true
    end,
    --  settings = {
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
  },
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
    settings = {
      gopls = {
        codelenses = { test = true },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = { unusedparams = true },
        staticcheck = true,
      },
    },
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
    filetypes = { "html" },
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
  tsserver = {
    on_attach = function(client)
      require("nvim-lsp-ts-utils").setup_client(client)
    end,
    settings = {
      javascript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    },
  },
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
  -- yamlls = {
  --   capabilities = {},
  --   settings = {
  --     yaml = {
  --       hover = true,
  --       completion = true,
  --       validate = true,
  --       customTags = {
  --         "!Base64",
  --         "!Cidr",
  --         "!FindInMap sequence",
  --         "!GetAtt",
  --         "!GetAZs",
  --         "!ImportValue",
  --         "!Join sequence",
  --         "!Ref",
  --         "!Select sequence",
  --         "!Split sequence",
  --         "!Sub sequence",
  --         "!Sub",
  --         "!And sequence",
  --         "!Condition",
  --         "!Equals sequence",
  --         "!If sequence",
  --         "!Not sequence",
  --         "!Or sequence",
  --       },
  --       editor = { formatOnType = true },
  --       schemas = yaml_schemas,
  --     },
  --   },
  -- },
  bashls = {},
}

for server, opts in pairs(servers) do
  if opts.capabilities == nil then
    opts.capabilities = caps
  end
  lspconfig[server].setup(opts)
end
