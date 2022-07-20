local ui = require("sh.ui")

vim.diagnostic.config({
  underline = true,
  virtual_text = false,
  signs = true,
  severity_sort = true,
  update_in_insert = false,
  float = {
    show_header = true,
    border = ui.borders,
    focusable = false,
  },
})
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  pattern = "*",
  callback = vim.diagnostic.open_float,
})
vim.fn.sign_define("DiagnosticSignError", {
  texthl = "DiagnosticSignError",
  text = "",
  numhl = "DiagnosticSignError",
})
vim.fn.sign_define("DiagnosticSignWarn", {
  texthl = "DiagnosticSignWarn",
  text = "",
  numhl = "DiagnosticSignWarn",
})
vim.fn.sign_define("DiagnosticSignHint", {
  texthl = "DiagnosticSignHint",
  text = "",
  numhl = "DiagnosticSignHint",
})
vim.fn.sign_define("DiagnosticSignInfo", {
  texthl = "DiagnosticSignInfo",
  text = "",
  numhl = "DiagnosticSignInfo",
})
