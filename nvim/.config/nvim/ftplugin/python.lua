local lspconfig = require('lspconfig')
local lsp = require('sh.lsp')

local function get_python_env() return {VIRTUAL_ENV = require('sh.utils').get_python_venv()} end

if not lsp.is_client_active("pylsp") then
    lspconfig.pylsp.setup {
        cmd = {"pylsp", "-v"},
        cmd_env = get_python_env(),
        on_attach = lsp.common_on_attach,
        capabilities = lsp.capabilities(),
        settings = {
            pylsp = {
                plugins = {flake8 = {enabled = true}, jedi_completion = {fuzzy = true}, pylsp_black = {enabled = true}, pylsp_mypy = {enabled = true}}
            }
        }
    }
    vim.cmd [[LspStart]]
end

vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
