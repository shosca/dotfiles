local au_lsp_codelens = vim.api.nvim_create_augroup("au_lsp_codelens", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_codelens", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
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
  end,
})
