local lsp = require('sh.lsp')
local lspconfig = require('lspconfig')

if not lsp.is_client_active('jsonls') then
  lspconfig.jsonls.setup {
    cmd = {"vscode-json-languageserver", "--stdio"},
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities(),
    commands = {Format = {function() vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line "$", 0}) end}},
    settings = {
      json = {
        schemas = {
          {fileMatch = {"package.json"}, url = "https://json.schemastore.org/package.json"},
          {fileMatch = {"tsconfig*.json"}, url = "https://json.schemastore.org/tsconfig.json"},
          {fileMatch = {".prettierrc", ".prettierrc.json", "prettier.config.json"}, url = "https://json.schemastore.org/prettierrc.json"},
          {fileMatch = {".eslintrc", ".eslintrc.json"}, url = "https://json.schemastore.org/eslintrc.json"},
          {fileMatch = {".babelrc", ".babelrc.json", "babel.config.json"}, url = "https://json.schemastore.org/babelrc.json"},
          {fileMatch = {"lerna.json"}, url = "https://json.schemastore.org/lerna.json"},
          {fileMatch = {"now.json", "vercel.json"}, url = "https://json.schemastore.org/now.json"},
          {fileMatch = {".stylelintrc", ".stylelintrc.json", "stylelint.config.json"}, url = "http://json.schemastore.org/stylelintrc.json"}
        }
      }
    }
  }
  vim.cmd [[LspStart]]
end
vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
