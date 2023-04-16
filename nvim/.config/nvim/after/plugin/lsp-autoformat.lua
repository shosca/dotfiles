local utils = require("sh.utils")

local au_lsp_doc_format = vim.api.nvim_create_augroup("au_lsp_doc_format", { clear = true })
utils.lsp_attach(function(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_clear_autocmds({ group = au_lsp_doc_format, buffer = bufnr, event = { "BufWritePre" } })
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      group = au_lsp_doc_format,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ timeout_ms = 20000 })
      end,
    })
  end
end)
