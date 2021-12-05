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
vim.fn.sign_define("DiagnosticSignError", {texthl = "DiagnosticSignError", text = "", numhl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {texthl = "DiagnosticSignWarn", text = "", numhl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignHint", {texthl = "DiagnosticSignHint", text = "", numhl = "DiagnosticSignHint"})
vim.fn.sign_define("DiagnosticSignInfo", {texthl = "DiagnosticSignInfo", text = "", numhl = "DiagnosticSignInfo"})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = border})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = border})
vim.diagnostic.config({virtual_text = false, signs = true, update_in_insert = false, underline = true, severity_sort = true})
vim.cmd("autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focusable=false, border=" .. vim.inspect(border) .. "})")

local caps = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then caps = cmp_nvim_lsp.update_capabilities(caps) end

local M = {capabilities = caps}
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
  local nnoremap = vim.keymap.nnoremap
  nnoremap {"gD", vim.lsp.buf.declaration, silent = true, buffer = bufnr}
  nnoremap {"gd", vim.lsp.buf.definition, silent = true, buffer = bufnr}
  nnoremap {"gi", vim.lsp.buf.implementation, silent = true, buffer = bufnr}
  nnoremap {"gr", vim.lsp.buf.references, silent = true, buffer = bufnr}
  nnoremap {"[d", vim.diagnostic.goto_prev, silent = true, buffer = bufnr}
  nnoremap {"]d", vim.diagnostic.goto_next, silent = true, buffer = bufnr}
  nnoremap {"gl", vim.lsp.buf.hover, silent = true, buffer = bufnr}
end

function M.cmp_config()
  local cmp = require('cmp')
  local cmp_types = require('cmp.types')
  require('sh.gh_issues')
  local lspkind = require('lspkind')
  lspkind.init()
  cmp.setup {
    completion = {completeopt = "menu,menuone,noselect"},
    snippet = {expand = function(args) require('luasnip').lsp_expand(args.body) end},
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<C-y>'] = cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Insert, select = true},
      ["<CR>"] = function(fallback)
        if cmp.visible() then
          return cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Replace, select = true}(fallback)
        else
          return fallback()
        end
      end,
      -- ['<C-n>'] = cmp.mapping.select_next_item(),
      ["<c-n>"] = function(fallback)
        if cmp.visible() then
          return cmp.mapping.select_next_item {behavior = cmp.SelectBehavior.Insert}(fallback)
        else
          return cmp.mapping.complete()(fallback)
        end
      end,
      -- ['<C-p>'] = cmp.mapping.select_prev_item(),
      ["<C-p>"] = cmp.mapping.select_prev_item {behavior = cmp.SelectBehavior.Insert}
    },
    formatting = {
      format = lspkind.cmp_format {
        with_text = true,
        menu = {
          nvim_lsp = "(LSP)",
          emoji = "(Emoji)",
          path = "(Path)",
          calc = "(Calc)",
          vsnip = "(Snippet)",
          luasnip = "(Snippet)",
          buffer = "(Buffer)",
          gh_issues = "(issues)"
        }
      }
    },
    sorting = {
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        require("cmp-under-comparator").under,
        function(entry1, entry2)
          local kind1 = entry1:get_kind()
          kind1 = kind1 == cmp_types.lsp.CompletionItemKind.Text and 100 or kind1
          kind1 = kind1 == cmp_types.lsp.CompletionItemKind.Variable and 1 or kind1
          local kind2 = entry2:get_kind()
          kind2 = kind2 == cmp_types.lsp.CompletionItemKind.Text and 100 or kind2
          kind2 = kind2 == cmp_types.lsp.CompletionItemKind.Variable and 1 or kind2
          if kind1 ~= kind2 then
            if kind1 == cmp_types.lsp.CompletionItemKind.Snippet then return true end
            if kind2 == cmp_types.lsp.CompletionItemKind.Snippet then return false end
            local diff = kind1 - kind2
            if diff < 0 then
              return true
            elseif diff > 0 then
              return false
            end
          end
        end,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order
      }
    },
    documentation = {border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}},
    sources = {
      {name = "gh_issues"},
      {name = "path", priority_weight = 110},
      {name = "nvim_lsp", max_item_count = 20, priority_weight = 100},
      {name = "nvim_lua", priority_weight = 90},
      {name = "luasnip", priority_weight = 80},
      {name = "buffer", max_item_count = 5, priority_weight = 70},
      {name = "rg", keyword_length = 5, max_item_count = 5, priority_weight = 60},
      {name = "tmux", max_item_count = 5, option = {all_panes = false}, priority_weight = 50},
      {name = "look", keyword_length = 5, max_item_count = 5, option = {convert_case = true, loud = true}, priority_weight = 40},
      {name = "zsh"},
      {name = "calc"},
      {name = "emoji"},
      {name = "treesitter"},
      {name = "crates"}
    },
    experimental = {native_menu = false, ghost_text = true}
  }
  -- cmp.setup.cmdline(":", {completion = {autocomplete = false}, sources = {{name = "cmdline"}}})
end

function M.is_client_active(name)
  local clients = vim.lsp.get_active_clients()
  for _, client in pairs(clients) do if client.name == name then return true end end
  return false
end

function M.configure_packer(use)
  use 'neovim/nvim-lspconfig'
  use 'folke/lua-dev.nvim'
  use 'nvim-lua/lsp-status.nvim'
  use {
    "hrsh7th/nvim-cmp",
    config = M.cmp_config,
    requires = {
      {"hrsh7th/cmp-cmdline"},
      {"andersevenrud/compe-tmux"},
      {"hrsh7th/cmp-buffer"},
      {"hrsh7th/cmp-nvim-lsp"},
      {"hrsh7th/cmp-nvim-lsp-document-symbol"},
      {"hrsh7th/cmp-nvim-lua"},
      {"hrsh7th/cmp-path"},
      {"saadparwaiz1/cmp_luasnip"},
      {"tamago324/cmp-zsh"},
      {"lukas-reineke/cmp-under-comparator"},
      {"lukas-reineke/cmp-rg"},
      {"octaltree/cmp-look"}
    }
  }
  use "onsails/lspkind-nvim"
end
return M
