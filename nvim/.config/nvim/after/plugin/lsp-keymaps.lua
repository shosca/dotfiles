local utils = require("sh.utils")
local nmap = require("sh.keymap").nmap

utils.lsp_attach(function(_, bufnr)
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
end)
