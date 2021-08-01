local lspconfig = require('lspconfig')
local lsp = require('sh.lsp')

local function get_python_env()
    return {VIRTUAL_ENV = require('sh.utils').get_python_venv()}
end

if not lsp.is_client_active('efm') then
    require('sh.efm').setup()
    vim.cmd [[LspStart]]
end

if not lsp.is_client_active("pylsp") then
    lspconfig.pylsp.setup {
        cmd_env = get_python_env(),
        on_attach = function(client, bufnr)
            lsp.common_on_attach(client, bufnr)
            client.resolved_capabilities.document_formatting = false
        end,
        capabilities = lsp.capabilities()
    }
    vim.cmd [[LspStart]]
end

vim.api
    .nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
