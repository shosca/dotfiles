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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_keymaps", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local nmap = require("sh.keymap").nmap
    nmap({ "gD", vim.lsp.buf.declaration, { silent = true, buffer = bufnr } })
    nmap({ "gd", vim.lsp.buf.definition, { silent = true, buffer = bufnr } })
    nmap({ "gi", vim.lsp.buf.implementation, { silent = true, buffer = bufnr } })
    nmap({ "gf", vim.lsp.buf.format, { silent = true, buffer = bufnr } })
    nmap({ "gr", vim.lsp.buf.references, { silent = true, buffer = bufnr } })
    nmap({ "gl", vim.lsp.buf.hover, { silent = true, buffer = bufnr } })
    nmap({ "gk", vim.lsp.buf.signature_help, { silent = true, buffer = bufnr } })
    nmap({ "ga", vim.lsp.buf.code_action, { silent = true, buffer = bufnr } })
    --xmap({ "la", vim.lsp.buf.range_code_action, { silent = true, buffer = bufnr } })
    nmap({ "[d", vim.diagnostic.goto_prev, { silent = true, buffer = bufnr } })
    nmap({ "]d", vim.diagnostic.goto_next, { silent = true, buffer = bufnr } })
  end,
})

local au_lsp_doc_format = vim.api.nvim_create_augroup("au_lsp_doc_format", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_doc_format", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
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
  end,
})

local au_lsp_codelens = vim.api.nvim_create_augroup("au_lsp_codelens", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_codelens", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.codeLensProvider then
      vim.api.nvim_clear_autocmds({
        group = au_lsp_codelens,
        buffer = bufnr,
        event = { "BufEnter", "BufWritePost", "CursorHold" },
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        group = au_lsp_codelens,
        buffer = bufnr,
        once = true,
        callback = vim.lsp.codelens.refresh,
      })
      vim.api.nvim_create_autocmd({ "BufWritePost", "CursorHold" }, {
        group = au_lsp_codelens,
        buffer = bufnr,
        callback = vim.lsp.codelens.refresh,
      })
    end
  end,
})

local au_lsp_doc_highlight = vim.api.nvim_create_augroup("au_lsp_doc_highlight", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_document_highlight", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.documentHighlightProvider then
      local highlight_event = { "CursorHold", "CursorHoldI" }
      local clear_event = { "CursorMoved", "WinLeave" }
      vim.api.nvim_clear_autocmds({ group = au_lsp_doc_highlight, buffer = bufnr, event = highlight_event })
      vim.api.nvim_clear_autocmds({ group = au_lsp_doc_highlight, buffer = bufnr, event = clear_event })
      vim.api.nvim_create_autocmd(highlight_event, {
        group = au_lsp_doc_highlight,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd(clear_event, {
        group = au_lsp_doc_highlight,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_inline_hints", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.documentHighlightProvider then
      local highlight_event = { "CursorHold", "CursorHoldI" }
      local clear_event = { "CursorMoved", "WinLeave" }
      vim.api.nvim_clear_autocmds({ group = au_lsp_doc_highlight, buffer = bufnr, event = highlight_event })
      vim.api.nvim_clear_autocmds({ group = au_lsp_doc_highlight, buffer = bufnr, event = clear_event })
      vim.api.nvim_create_autocmd(highlight_event, {
        group = au_lsp_doc_highlight,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd(clear_event, {
        group = au_lsp_doc_highlight,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_navic", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, bufnr)
    end
  end,
})

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
  tsserver = {
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
  if opts.capabilities == nil then
    opts.capabilities = lsp.capabilities
  end
  lspconfig[server].setup(opts)
end

local nullls = require("null-ls")
nullls.setup({
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
