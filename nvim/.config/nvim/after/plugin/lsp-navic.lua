vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_navic", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, bufnr)
    end
  end,
})
