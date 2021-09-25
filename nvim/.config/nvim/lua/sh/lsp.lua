local border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
vim.lsp.protocol.CompletionItemKind = {
  "   (Text) ",
  "   (Method)",
  "   (Function)",
  "   (Constructor)",
  " ﴲ  (Field)",
  "[] (Variable)",
  "   (Class)",
  " ﰮ  (Interface)",
  "   (Module)",
  " 襁 (Property)",
  "   (Unit)",
  "   (Value)",
  " 練 (Enum)",
  "   (Keyword)",
  "   (Snippet)",
  "   (Color)",
  "   (File)",
  "   (Reference)",
  "   (Folder)",
  "   (EnumMember)",
  " ﲀ  (Constant)",
  " ﳤ  (Struct)",
  "   (Event)",
  "   (Operator)",
  "   (TypeParameter)"
}
vim.fn.sign_define("LspDiagnosticsSignError", {texthl = "LspDiagnosticsSignError", text = "", numhl = "LspDiagnosticsSignError"})
vim.fn.sign_define("LspDiagnosticsSignWarning", {texthl = "LspDiagnosticsSignWarning", text = "", numhl = "LspDiagnosticsSignWarning"})
vim.fn.sign_define("LspDiagnosticsSignHint", {texthl = "LspDiagnosticsSignHint", text = "", numhl = "LspDiagnosticsSignHint"})
vim.fn.sign_define("LspDiagnosticsSignInformation", {texthl = "LspDiagnosticsSignInformation", text = "", numhl = "LspDiagnosticsSignInformation"})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = border})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = border})
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  signs = {
    active = true,
    values = {
      {name = "LspDiagnosticsSignError", text = ""},
      {name = "LspDiagnosticsSignWarning", text = ""},
      {name = "LspDiagnosticsSignHint", text = ""},
      {name = "LspDiagnosticsSignInformation", text = ""}
    }
  },
  virtual_text = false,
  underline = true,
  severity_sort = true
})
vim.cmd("autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false, border=" .. vim.inspect(border) .. "})")

local M = {}
function M.common_on_attach(client, bufnr)
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceText cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=#464646
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
      ]], false)
  end

  local opts = {noremap = true, silent = true}
  local function map(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  map("n", "gp", "<cmd>lua require'lsp'.PeekDefinition()<CR>", opts)
  map("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  map("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
end

function M.cmp_config()
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  cmp.setup {
    completion = {completeopt = "menu,menuone,noselect"},
    snippet = {expand = function(args) luasnip.lsp_expand(args.body) end},
    mapping = {
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Replace, select = true},
      ['<Tab>'] = function(fallback)
        if vim.fn.pumvisible() == 1 then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
        elseif luasnip.expand_or_jumpable() then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if vim.fn.pumvisible() == 1 then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
        elseif luasnip.jumpable(-1) then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
        else
          fallback()
        end
      end
    },
    formatting = {
      format = function(entry, vim_item)
        vim_item.kind = require("lspkind").presets.default[vim_item.kind]
        vim_item.menu = ({
          nvim_lsp = "(LSP)",
          emoji = "(Emoji)",
          path = "(Path)",
          calc = "(Calc)",
          vsnip = "(Snippet)",
          luasnip = "(Snippet)",
          buffer = "(Buffer)"
        })[entry.source.name]
        vim_item.dup = ({buffer = 1, path = 1, nvim_lsp = 0})[entry.source.name] or 0
        return vim_item
      end
    },
    documentation = {border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}},
    sources = {
      {name = "nvim_lsp"},
      {name = "luasnip"},
      {name = "nvim_lua"},
      {name = "path"},
      {name = "buffer"},
      {name = "calc"},
      {name = "emoji"},
      {name = "treesitter"},
      {name = "crates"}
    }
  }
end

function M.is_client_active(name)
  local clients = vim.lsp.get_active_clients()
  for _, client in pairs(clients) do if client.name == name then return true end end
  return false
end

function M.capabilities() return require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()) end

function M.configure_packer(use)
  use 'neovim/nvim-lspconfig'
  use 'folke/lua-dev.nvim'
  use 'nvim-lua/lsp-status.nvim'
  use {
    "hrsh7th/nvim-cmp",
    config = M.cmp_config,
    requires = {
      "L3MON4D3/LuaSnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim"
    }
  }
  use {'folke/todo-comments.nvim', requires = 'nvim-lua/plenary.nvim', config = function() require('todo-comments').setup() end}
end
return M
