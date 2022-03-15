local lsp = require('sh.lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active('yamlls') then
  lspconfig.yamlls.setup {
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities,
    settings = {
      yaml = {
        hover = true,
        completion = true,
        validate = true,
        customTags = {
          "!Ref",
          "!GetAtt",
          "!fn",
          "!And",
          "!If",
          "!Not",
          "!Equals",
          "!Or",
          "!FindInMap sequence",
          "!Base64",
          "!Cidr",
          "!Sub",
          "!GetAZs",
          "!ImportValue",
          "!Select",
          "!Split",
          "!Join sequence"
        },
        editor = {formatOnType = true},
        schemaStore = {enable = true, url = "https://www.schemastore.org/api/json/catalog.json"},
        schemas = {
          {
            url = "https://raw.githubusercontent.com/docker/cli/master/cli/compose/schema/data/config_schema_v3.9.json",
            fileMatch = "*compose.{yml, yaml}"
          },
          {
            url = "https://raw.githubusercontent.com/docker/cli/master/cli/compose/schema/data/config_schema_v3.9.json",
            fileMatch = "*compose.override.{yml, yaml}"
          },
          {url = 'https://json.schemastore.org/pre-commit-config.json', fileMatch = '.pre-commit-config.{yml,yaml}'},
          {
            url = 'https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json',
            fileMatch = {'**/cf-templates/**/*.{yml,yaml}'}

          },
          {url = 'https://json.schemastore.org/github-action', fileMatch = '.github/action.{yml,yaml}'},
          {url = 'https://json.schemastore.org/ansible-stable-2.9', fileMatch = 'roles/tasks/*.{yml,yaml}'},
          {url = 'https://json.schemastore.org/prettierrc', fileMatch = '.prettierrc.{yml,yaml}'},
          {url = 'https://json.schemastore.org/stylelintrc', fileMatch = '.stylelintrc.{yml,yaml}'},
          {url = 'https://json.schemastore.org/circleciconfig', fileMatch = '.circleci/**/*.{yml,yaml}'},
          {url = "https://yarnpkg.com/configuration/yarnrc.json", fileMatch = ".yarnrc.{yml,yaml}"}
        }
      }
    }
  }

  vim.cmd [[LspStart]]
end
