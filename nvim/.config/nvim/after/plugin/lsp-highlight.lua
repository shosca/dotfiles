local utils = require("sh.utils")
local au_lsp_doc_highlight = vim.api.nvim_create_augroup("au_lsp_doc_highlight", { clear = true })

utils.lsp_attach(function(client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    local highlight_event = { "CursorHold", "CursorHoldI" }
    local clear_event = { "CursorMoved", "WinLeave" }
    vim.api.nvim_clear_autocmds({ group = au_lsp_doc_highlight, buffer = bufnr, event = highlight_event })
    vim.api.nvim_clear_autocmds({ group = au_lsp_doc_highlight, buffer = bufnr, event = clear_event })
    vim.api.nvim_create_autocmd(highlight_event, {
      group = au_lsp_doc_highlight,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd(clear_event, {
      group = au_lsp_doc_highlight,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end)
