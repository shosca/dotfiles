local lspconfig = require('lspconfig')
local lsputil = require('lspconfig/util')
local lsp = require('sh.lsp')

local M = {}

function M.setup()
    local venv = require('sh.utils').get_python_venv()
    local python_setup = {}
    local bin_path = ''
    if venv then bin_path = lsputil.path.join(venv, 'bin') .. '/' end
    local flake8 = {
        LintCommand = bin_path .. 'flake8 --stdin-display-name ${INPUT} -',
        lintStdin = true,
        lintFormats = {'%f:%l:%c: %m'}
    }
    table.insert(python_setup, flake8)

    local mypy = {
        LintCommand = bin_path .. 'mypy --show-column-numbers',
        lintFormats = {
            '%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m',
            '%f:%l:%c: %tote: %m'
        }
    }
    table.insert(python_setup, mypy)
    local black = {
        LintCommand = bin_path .. 'black --quiet -',
        lintStdin = true
    }
    table.insert(python_setup, black)

    local lua_setup = {}
    local luaformat = {formatCommand = 'lua-format -i', formatStdin = true}
    table.insert(lua_setup, luaformat)

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
            rootMarkers = {
                ".git", "poetry.lock", "pyproject.toml", "Pipfile",
                "requirements.txt", "requirements.in", "setup.cfg", "setup.py"
            },
            languages = {python = python_setup, lua = lua_setup}
        }
    }

end

return M
