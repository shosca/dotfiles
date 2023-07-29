require("sh.utils").lsp_attach(function(client, bufnr)
  local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
  if inlay_hint and client.supports_method("textDocument/inlayHint") then
    inlay_hint(bufnr, true)
  end
end)
