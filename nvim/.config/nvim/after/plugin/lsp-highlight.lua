local au_lsp_doc_highlight = vim.api.nvim_create_augroup("au_lsp_doc_highlight", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_document_highlight", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
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
  end,
})
