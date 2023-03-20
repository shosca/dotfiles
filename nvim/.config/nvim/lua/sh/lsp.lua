local caps = vim.lsp.protocol.make_client_capabilities()
caps.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
caps.textDocument.completion.completionItem.snippetSupport = true
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  caps = cmp_nvim_lsp.default_capabilities(caps)
end

local M = {
  capabilities = caps,
}

function M.is_client_active(name)
  local clients = vim.lsp.get_active_clients()
  for _, client in pairs(clients) do
    if client.name == name then
      return true
    end
  end
  return false
end

return M
