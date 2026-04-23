local utils = require("sh.utils")
local wk = require("which-key")

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end
vim.lsp.config("*", { capabilities = caps })

local servers = {
  "bashls",
  "biome",
  "clang",
  "crystalline",
  "dockerls",
  "gopls",
  "html",
  "jsonls",
  "kotlin_language_server",
  "omnisharp",
  "pyrefly",
  "ruff",
  "rust_analyzer",
  "solargraph",
  "sorbet",
  "terraformls",
  "tombi",
  "tsgo",
  "yamlls",
  "zls",
  -- "pylsp",
  -- "ts_ls",
  -- "vtsls",
  -- "zubanls",
}
for _, server in pairs(servers) do
  vim.lsp.enable(server)
end

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

utils.lsp_attach(function(_, bufnr)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { silent = true, buffer = bufnr, desc = "Go to declaration" })
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true, buffer = bufnr, desc = "Go to definition" })
  vim.keymap.set(
    "n",
    "gi",
    vim.lsp.buf.implementation,
    { silent = true, buffer = bufnr, desc = "Go to implementation" }
  )
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Type definition" })
  vim.keymap.set("n", "gf", vim.lsp.buf.format, { silent = true, buffer = bufnr, desc = "Format" })
  vim.keymap.set("n", "gu", vim.lsp.buf.references, { silent = true, buffer = bufnr, desc = "References" })
  vim.keymap.set("n", "gr", vim.lsp.buf.rename, { silent = true, buffer = bufnr, desc = "Rename" })
  vim.keymap.set("n", "gl", vim.lsp.buf.hover, { silent = true, buffer = bufnr, desc = "Hover" })
  vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, { silent = true, buffer = bufnr, desc = "Signature help" })
  vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, { silent = true, buffer = bufnr, desc = "Code action" })
  --xmap({ "la", vim.lsp.buf.range_code_action, { silent = true, buffer = bufnr } })
  vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = 1 })
  end, { silent = true, buffer = bufnr })
  vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = -1 })
  end, { silent = true, buffer = bufnr })
end)

utils.lsp_attach(function(client, bufnr)
  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
    local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = bufnr,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
      group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
      callback = function(e)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = e.buf })
      end,
    })
  end
end)
