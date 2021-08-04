local lsp = require('sh.lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active('yamlls') then
    lspconfig.yamlls.setup {
        on_attach = lsp.common_on_attach,
        capabilities = lsp.capabilities(),
        settings = {
            yaml = {
                customTags = {
                    "!Ref", "!GetAtt", "!fn", "!And", "!If", "!Not", "!Equals", "!Or", "!FindInMap sequence", "!Base64", "!Cidr", "!Sub", "!GetAZs",
                    "!ImportValue", "!Select", "!Split", "!Join sequence"
                },
                schemas = {
                    {url = 'https://json.schemastore.org/pre-commit-config.json', fileMatch = '.pre-commit-config.{yml,yaml}'}, {
                        url = 'https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json',
                        fileMatch = {'cf-templates/**/*.{yml,yaml}'}

                    }, {url = 'https://json.schemastore.org/github-action', fileMatch = '.github/action.{yml,yaml}'},
                    {url = 'https://json.schemastore.org/ansible-stable-2.9', fileMatch = 'roles/tasks/*.{yml,yaml}'},
                    {url = 'https://json.schemastore.org/prettierrc', fileMatch = '.prettierrc.{yml,yaml}'},
                    {url = 'https://json.schemastore.org/stylelintrc', fileMatch = '.stylelintrc.{yml,yaml}'},
                    {url = 'https://json.schemastore.org/circleciconfig', fileMatch = '.circleci/**/*.{yml,yaml}'}
                }
            }
        }
    }

    vim.cmd [[LspStart]]
end
