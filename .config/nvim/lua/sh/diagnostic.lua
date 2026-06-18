local ui = require("sh.ui")

vim.diagnostic.config({
  underline = true,
  virtual_text = false,
  severity_sort = true,
  update_in_insert = true,
  float = {
    style = "minimal",
    show_header = true,
    border = ui.borders,
    focusable = false,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ui.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = ui.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = ui.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = ui.diagnostics.Info,
    },
  },
})
