local ui = require("sh.ui")

vim.lsp.handlers["textDocument/definition"] = function(_, result)
  if not result or vim.tbl_isempty(result) then
    print("[LSP] Could not find definition")
    return
  end

  if vim.tbl_islist(result) then
    vim.lsp.util.jump_to_location(result[1], "utf-8", true)
  else
    vim.lsp.util.jump_to_location(result, "utf-8", true)
  end
end
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = ui.borders })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = ui.borders })

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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_inline_hints", {}),
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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach_inlay_hints", {}),
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require("inlay-hints").on_attach(client, bufnr)
  end,
})
