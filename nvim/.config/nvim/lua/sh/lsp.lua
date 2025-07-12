local utils = require("sh.utils")
local lspconfig = require("lspconfig")
local lspstatus = require("lsp-status")
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
        workspace = {
          checkThirdParty = false,
        },
        telemetry = { enable = false },
        hint = { enable = true },
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
  --     new_config.cmd_env = u.get_python_env({ root = root })
  --     return true
  --   end,
  -- },
  pylsp = {
    cmd = { "pylsp", "-v", "--log-file", vim.fs.joinpath(vim.fn.stdpath("state"), "pylsp.log") },
    flags = { debounce_text_changes = 200 },
    settings = {
      pylsp = {
        plugins = {
          ruff = {
            enabled = false,
            formatEnabled = true,
          },
          flake8 = {
            enabled = false,
          },
          black = {
            enabled = true,
          },
          pylsp_mypy = {
            enabled = true,
            live_mode = true,
            dmypy = false,
            report_progress = true,
          },
          rope_autoimport = {
            enabled = false,
          },
        },
      },
    },
  },
  ruff = {},
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
  -- eslint = {
  --   format = false,
  -- },
  biome = { cmd = { "yarn", "biome", "lsp-proxy" } },
  ts_ls = {
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
        preferences = {
          includeCompletionsForModuleExports = true,
          includeCompletionsForImportStatements = true,
          importModuleSpecifierPreference = "relative",
        },
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
        format = { enable = false },
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  },
  yamlls = {
    capabilities = {},
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
        schemas = require("schemastore").yaml.schemas(),
      },
    },
  },
  bashls = {},
}

for server, opts in pairs(servers) do
  if opts.capabilities == nil then
    opts.capabilities = caps
  end
  lspconfig[server].setup(opts)
end

local au_lsp_doc_format = vim.api.nvim_create_augroup("au_lsp_doc_format", { clear = true })
utils.lsp_attach(function(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_clear_autocmds({ group = au_lsp_doc_format, buffer = bufnr, event = { "BufWritePre" } })
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      group = au_lsp_doc_format,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ timeout_ms = 20000 })
      end,
    })
  end
end)

utils.lsp_attach(function(_, bufnr)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { silent = true, buffer = bufnr })
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true, buffer = bufnr })
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { silent = true, buffer = bufnr })
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = 0 })
  vim.keymap.set("n", "gf", vim.lsp.buf.format, { silent = true, buffer = bufnr })
  vim.keymap.set("n", "gr", vim.lsp.buf.references, { silent = true, buffer = bufnr })
  vim.keymap.set("n", "gl", vim.lsp.buf.hover, { silent = true, buffer = bufnr })
  vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, { silent = true, buffer = bufnr })
  vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, { silent = true, buffer = bufnr })
  --xmap({ "la", vim.lsp.buf.range_code_action, { silent = true, buffer = bufnr } })
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { silent = true, buffer = bufnr })
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { silent = true, buffer = bufnr })
end)
