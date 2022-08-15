local lspconfig = require("lspconfig")
local lsp = require("sh.lsp")
local secrets = require("sh.secrets")
local lspstatus = require("lsp-status")
local luadev = require("lua-dev").setup({
  library = { plugins = { "neotest" }, types = true },
})

local servers = {
  sumneko_lua = luadev,
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
  },
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
    settings = {
      pylsp = {
        plugins = {
          flake8 = { enabled = false },
          mccabe = { enabled = false },
          pyflakes = { enabled = false },
          pycodestyle = { enabled = false },
          jedi_completion = { include_params = true, fuzzy = true },
          pylsp_black = { enabled = false },
          pylsp_mypy = { enabled = false },
          rope_completion = { enabled = true },
          rope_rename = { enabled = true },
        },
      },
    },
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
    settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } },
  },
  crystalline = { on_attach = lsp.common_on_attach, capabilities = lsp.capabilities },
  omnisharp = {
    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  },
  cssls = {
    cmd = { "vscode-css-languageserver", "--stdio" },
  },
  dockerls = { on_attach = lsp.common_on_attach, capabilities = lsp.capabilities },
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
  kotlin_language_server = { on_attach = lsp.on_attach, capabilities = lsp.capabilities },
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
        schemas = {
          {
            description = "TypeScript compiler configuration file",
            fileMatch = { "tsconfig.json", "tsconfig.*.json" },
            url = "https://json.schemastore.org/tsconfig.json",
          },
          {
            description = "Lerna config",
            fileMatch = { "lerna.json" },
            url = "https://json.schemastore.org/lerna.json",
          },
          {
            description = "Babel configuration",
            fileMatch = { ".babelrc.json", ".babelrc", "babel.config.json" },
            url = "https://json.schemastore.org/babelrc.json",
          },
          {
            description = "ESLint config",
            fileMatch = { ".eslintrc.json", ".eslintrc" },
            url = "https://json.schemastore.org/eslintrc.json",
          },
          {
            description = "Bucklescript config",
            fileMatch = { "bsconfig.json" },
            url = "https://raw.githubusercontent.com/rescript-lang/rescript-compiler/8.2.0/docs/docson/build-schema.json",
          },
          {
            description = "Prettier config",
            fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
            url = "https://json.schemastore.org/prettierrc",
          },
          {
            description = "Vercel Now config",
            fileMatch = { "now.json" },
            url = "https://json.schemastore.org/now",
          },
          {
            description = "Stylelint config",
            fileMatch = { ".stylelintrc", ".stylelintrc.json", "stylelint.config.json" },
            url = "https://json.schemastore.org/stylelintrc",
          },
          {
            description = "A JSON schema for the ASP.NET LaunchSettings.json files",
            fileMatch = { "launchsettings.json" },
            url = "https://json.schemastore.org/launchsettings.json",
          },
          {
            description = "Schema for CMake Presets",
            fileMatch = { "CMakePresets.json", "CMakeUserPresets.json" },
            url = "https://raw.githubusercontent.com/Kitware/CMake/master/Help/manual/presets/schema.json",
          },
          {
            description = "Configuration file as an alternative for configuring your repository in the settings page.",
            fileMatch = { ".codeclimate.json" },
            url = "https://json.schemastore.org/codeclimate.json",
          },
          {
            description = "LLVM compilation database",
            fileMatch = { "compile_commands.json" },
            url = "https://json.schemastore.org/compile-commands.json",
          },
          {
            description = "Config file for Command Task Runner",
            fileMatch = { "commands.json" },
            url = "https://json.schemastore.org/commands.json",
          },
          {
            description = "AWS CloudFormation provides a common language for you to describe and provision all the infrastructure resources in your cloud environment.",
            fileMatch = { "*.cf.json", "cloudformation.json" },
            url = "https://raw.githubusercontent.com/awslabs/goformation/v5.2.9/schema/cloudformation.schema.json",
          },
          {
            description = "The AWS Serverless Application Model (AWS SAM, previously known as Project Flourish) extends AWS CloudFormation to provide a simplified way of defining the Amazon API Gateway APIs, AWS Lambda functions, and Amazon DynamoDB tables needed by your serverless application.",
            fileMatch = { "serverless.template", "*.sam.json", "sam.json" },
            url = "https://raw.githubusercontent.com/awslabs/goformation/v5.2.9/schema/sam.schema.json",
          },
          {
            description = "Json schema for properties json file for a GitHub Workflow template",
            fileMatch = { ".github/workflow-templates/**.properties.json" },
            url = "https://json.schemastore.org/github-workflow-template-properties.json",
          },
          {
            description = "golangci-lint configuration file",
            fileMatch = { ".golangci.toml", ".golangci.json" },
            url = "https://json.schemastore.org/golangci-lint.json",
          },
          {
            description = "JSON schema for the JSON Feed format",
            fileMatch = { "feed.json" },
            url = "https://json.schemastore.org/feed.json",
            versions = {
              ["1"] = "https://json.schemastore.org/feed-1.json",
              ["1.1"] = "https://json.schemastore.org/feed.json",
            },
          },
          {
            description = "Packer template JSON configuration",
            fileMatch = { "packer.json" },
            url = "https://json.schemastore.org/packer.json",
          },
          {
            description = "NPM configuration file",
            fileMatch = { "package.json" },
            url = "https://json.schemastore.org/package.json",
          },
          {
            description = "JSON schema for Visual Studio component configuration files",
            fileMatch = { "*.vsconfig" },
            url = "https://json.schemastore.org/vsconfig.json",
          },
          {
            description = "Resume json",
            fileMatch = { "resume.json" },
            url = "https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json",
          },
        },
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
        schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
        schemas = {
          kubernetes = { "helm/*.yaml", "kube/*.yaml" },
          ["https://json.schemastore.org/ansible-playbook"] = {
            "playbook.{yml,yaml}",
            "playbooks/*{yml,yaml}",
          },
          ["https://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
          ["https://json.schemastore.org/bamboo-spec.json"] = "bamboo-specs/*.{yml,yaml}",
          ["https://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
          ["https://json.schemastore.org/github-action"] = ".github/*.{yml,yaml}",
          ["https://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
          ["https://json.schemastore.org/gitlab-ci"] = "/*lab-ci.{yml,yaml}",
          ["https://json.schemastore.org/gitlab-ci.json"] = { ".gitlab-ci.yml" },
          ["https://json.schemastore.org/helmfile"] = "helmfile.{yml,yaml}",
          ["https://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
          ["https://json.schemastore.org/pre-commit-config.json"] = ".pre-commit-config.{yml,yaml}",
          ["https://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
          ["https://json.schemastore.org/stylelintrc"] = ".stylelintrc.{yml,yaml}",
          ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = "**/cf-templates/**/*.{yml,yaml}",
          ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
            "docker-compose*.{yml,yaml}",
          },
          ["https://raw.githubusercontent.com/docker/cli/master/cli/compose/schema/data/config_schema_v3.9.json"] = "*compose.override.{yml, yaml}",
          ["https://yarnpkg.com/configuration/yarnrc.json"] = ".yarnrc.{yml,yaml}",
        },
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
