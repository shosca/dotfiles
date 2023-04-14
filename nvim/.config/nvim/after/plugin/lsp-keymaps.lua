vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_keymaps", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local nmap = require("sh.keymap").nmap
    nmap({ "gD", vim.lsp.buf.declaration, { silent = true, buffer = bufnr } })
    nmap({ "gd", vim.lsp.buf.definition, { silent = true, buffer = bufnr } })
    nmap({ "gi", vim.lsp.buf.implementation, { silent = true, buffer = bufnr } })
    nmap({ "gf", vim.lsp.buf.format, { silent = true, buffer = bufnr } })
    nmap({ "gr", vim.lsp.buf.references, { silent = true, buffer = bufnr } })
    nmap({ "gl", vim.lsp.buf.hover, { silent = true, buffer = bufnr } })
    nmap({ "gk", vim.lsp.buf.signature_help, { silent = true, buffer = bufnr } })
    nmap({ "ga", vim.lsp.buf.code_action, { silent = true, buffer = bufnr } })
    --xmap({ "la", vim.lsp.buf.range_code_action, { silent = true, buffer = bufnr } })
    nmap({ "[d", vim.diagnostic.goto_prev, { silent = true, buffer = bufnr } })
    nmap({ "]d", vim.diagnostic.goto_next, { silent = true, buffer = bufnr } })
  end,
})
