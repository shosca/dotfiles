local lspconfig = require('lspconfig')
local lsputil = require('lspconfig/util')
local lsp = require('sh.lsp')

local M = {}

function M.get_python_setup()
    local venv = require('sh.utils').get_python_venv()
    local bin_path = ''
    if venv then bin_path = lsputil.path.join(venv, 'bin') .. '/' end

    local root_markers = {
        ".git", "poetry.lock", "pyproject.toml", "Pipfile", "requirements.txt",
        "requirements.in", "setup.cfg", "setup.py"
    }

    return {
        {
            lintCommand = bin_path .. 'flake8',
            lintIgnoreExitCode = true,
            lintFormats = {'%f:%l:%c: %m'},
            rootMarkers = root_markers
        }, {
            lintCommand = bin_path .. 'mypy --show-column-numbers',
            lintFormats = {
                '%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m',
                '%f:%l:%c: %tote: %m'
            },
            rootMarkers = root_markers
        }, {
            formatCommand = bin_path .. 'black --quiet -',
            formatStdin = true,
            rootMarkers = root_markers
        }
    }
end

function M.lua_setup()
    return {
        {
            formatCommand = 'lua-format -i',
            formatStdin = true,
            rootMarkers = {".git"}
        }
    }
end

function M.setup()

    lspconfig.efm.setup {
        on_attach = lsp.common_on_attach,
        capabilities = lsp.capabilities(),
        init_options = {
            documentFormatting = true,
            documentSymbol = true,
            codeAction = true,
            hover = true
        },
        filetypes = {"python", "lua"},
        settings = {
            languages = {python = M.get_python_setup(), lua = M.lua_setup()}
        }
    }

end

return M
