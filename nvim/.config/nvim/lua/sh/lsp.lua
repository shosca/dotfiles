local utils = require("sh.utils")

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

local au_lsp_doc_highlight = vim.api.nvim_create_augroup("au_lsp_doc_highlight", { clear = true })
function M.on_attach_lsp_document_highlight(client, bufnr)
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
end

local au_lsp_codelens = vim.api.nvim_create_augroup("au_lsp_codelens", { clear = true })
function M.on_attach_lsp_code_lens(client, bufnr)
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
end

local au_lsp_doc_format = vim.api.nvim_create_augroup("au_lsp_doc_format", { clear = true })
function M.on_attach_lsp_document_formatting(client, bufnr)
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
end

function M.on_attach_lsp_keymaps(_, bufnr)
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
end

function M.common_on_attach(client, bufnr)
  for key, value in pairs(M) do
    if utils.starts_with(key, "on_attach") then
      value(client, bufnr)
    end
  end
end

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
