local lsp = require('sh.lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active('yamlls') then
  lspconfig.yamlls.setup({
    on_attach = lsp.common_on_attach,
    capabilities = lsp.capabilities,
    settings = {
      yaml = {
        hover = true,
        completion = true,
        validate = true,
        customTags = {
          '!Ref',
          '!GetAtt',
          '!fn',
          '!And',
          '!If',
          '!Not',
          '!Equals',
          '!Or',
          '!FindInMap sequence',
          '!Base64',
          '!Cidr',
          '!Sub',
          '!GetAZs',
          '!ImportValue',
          '!Select',
          '!Split',
          '!Join sequence',
        },
        editor = { formatOnType = true },
        schemaStore = { enable = true, url = 'https://www.schemastore.org/api/json/catalog.json' },
        schemas = {
          kubernetes = { 'helm/*.yaml', 'kube/*.yaml' },
          ['https://json.schemastore.org/ansible-playbook'] = {
            'playbook.{yml,yaml}',
            'playbooks/*{yml,yaml}',
          },
          ['https://json.schemastore.org/ansible-stable-2.9'] = 'roles/tasks/*.{yml,yaml}',
          ['https://json.schemastore.org/bamboo-spec.json'] = 'bamboo-specs/*.{yml,yaml}',
          ['https://json.schemastore.org/circleciconfig'] = '.circleci/**/*.{yml,yaml}',
          ['https://json.schemastore.org/github-action'] = '.github/*.{yml,yaml}',
          ['https://json.schemastore.org/github-workflow'] = '.github/workflows/*.{yml,yaml}',
          ['https://json.schemastore.org/gitlab-ci'] = '/*lab-ci.{yml,yaml}',
          ['https://json.schemastore.org/gitlab-ci.json'] = { '.gitlab-ci.yml' },
          ['https://json.schemastore.org/helmfile'] = 'helmfile.{yml,yaml}',
          ['https://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
          ['https://json.schemastore.org/pre-commit-config.json'] = '.pre-commit-config.{yml,yaml}',
          ['https://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
          ['https://json.schemastore.org/stylelintrc'] = '.stylelintrc.{yml,yaml}',
          ['https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json'] = '**/cf-templates/**/*.{yml,yaml}',
          ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = {
            'docker-compose*.{yml,yaml}',
          },
          ['https://raw.githubusercontent.com/docker/cli/master/cli/compose/schema/data/config_schema_v3.9.json'] = '*compose.override.{yml, yaml}',
          ['https://yarnpkg.com/configuration/yarnrc.json'] = '.yarnrc.{yml,yaml}',
        },
      },
    },
  })

  vim.cmd([[LspStart]])
end
