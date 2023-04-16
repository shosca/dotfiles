local utils = require("sh.utils")

local au_lsp_codelens = vim.api.nvim_create_augroup("au_lsp_codelens", { clear = true })

utils.lsp_attach(function(client, bufnr)
  if client.server_capabilities.codeLensProvider then
    vim.api.nvim_clear_autocmds({
      group = au_lsp_codelens,
      buffer = bufnr,
      event = { "BufEnter", "BufWritePost", "CursorHold" },
    })
    vim.api.nvim_create_autocmd("BufEnter", {
      group = au_lsp_codelens,
      buffer = bufnr,
      once = true,
      callback = vim.lsp.codelens.refresh,
    })
    vim.api.nvim_create_autocmd({ "BufWritePost", "CursorHold" }, {
      group = au_lsp_codelens,
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
    })
  end
end)
