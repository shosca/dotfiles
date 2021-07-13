local lsp = require('lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active("sumneko_lua") then
  lspconfig.sumneko_lua.setup {
    cmd = { "lua-language-server" },
    on_attach = lsp.common_on_attach,
    settings = {
      Lua = {
        runtime = {
          version = "LuaJit",
          path = vim.split(package.path, ";"),
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim", "require" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 1000,
        }
      }
    }
  }
  vim.cmd [[LspStart]]
end
