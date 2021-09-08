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

-- scroll down hover doc or scroll in definition preview
-- scroll up hover doc
vim.cmd 'command! -nargs=0 LspVirtualTextToggle lua require("lsp/virtual_text").toggle()'

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
  cmp.setup {
    snippet = {expand = function(args) require("luasnip").lsp_expand(args.body) end},
    mapping = {
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-e>"] = cmp.mapping.close(),
      ["<c-y>"] = cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Insert, select = true}
    },
    formatting = {
      format = function(entry, vim_item)
        vim_item.kind = require("lspkind").presets.default[vim_item.kind]
        vim_item.menu = entry.source.name
        return vim_item
      end
    },
    sources = {{name = "buffer"}, {name = "path"}, {name = "nvim_lua"}, {name = "nvim_lsp"}, {name = "luasnip"}}
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
