return {
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
      format = { enable = false },
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}
