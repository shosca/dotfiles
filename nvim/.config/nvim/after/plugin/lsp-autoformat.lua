local au_lsp_doc_format = vim.api.nvim_create_augroup("au_lsp_doc_format", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_doc_format", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
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
  end,
})
