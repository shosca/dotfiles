local ui = require("sh.ui")

vim.diagnostic.config({
  underline = true,
  virtual_text = false,
  signs = true,
  severity_sort = true,
  update_in_insert = true,
  float = {
    style = "minimal",
    show_header = true,
    border = ui.borders,
    focusable = false,
  },
})
-- vim.api.nvim_create_autocmd({ "CursorHold" }, {
--   pattern = "*",
--   callback = vim.diagnostic.open_float,
-- })

for name, icon in pairs(require("sh.ui").diagnostics) do
  name = "DiagnosticSign" .. name
  vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
end
