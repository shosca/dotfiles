local border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
vim.lsp.protocol.CompletionItemKind = {
  '   (Text) ',
  '   (Method)',
  '   (Function)',
  '   (Constructor)',
  ' ﴲ  (Field)',
  '[] (Variable)',
  '   (Class)',
  ' ﰮ  (Interface)',
  '   (Module)',
  ' 襁 (Property)',
  '   (Unit)',
  '   (Value)',
  ' 練 (Enum)',
  '   (Keyword)',
  '   (Snippet)',
  '   (Color)',
  '   (File)',
  '   (Reference)',
  '   (Folder)',
  '   (EnumMember)',
  ' ﲀ  (Constant)',
  ' ﳤ  (Struct)',
  '   (Event)',
  '   (Operator)',
  '   (TypeParameter)',
}
vim.fn.sign_define('DiagnosticSignError', {
  texthl = 'DiagnosticSignError',
  text = '',
  numhl = 'DiagnosticSignError',
})
vim.fn.sign_define('DiagnosticSignWarn', {
  texthl = 'DiagnosticSignWarn',
  text = '',
  numhl = 'DiagnosticSignWarn',
})
vim.fn.sign_define('DiagnosticSignHint', {
  texthl = 'DiagnosticSignHint',
  text = '',
  numhl = 'DiagnosticSignHint',
})
vim.fn.sign_define('DiagnosticSignInfo', {
  texthl = 'DiagnosticSignInfo',
  text = '',
  numhl = 'DiagnosticSignInfo',
})

vim.lsp.handlers['textDocument/definition'] = function(_, result)
  if not result or vim.tbl_isempty(result) then
    print('[LSP] Could not find definition')
    return
  end

  if vim.tbl_islist(result) then
    vim.lsp.util.jump_to_location(result[1])
  else
    vim.lsp.util.jump_to_location(result)
  end
end
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
})
vim.cmd('autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focusable=false, border=' .. vim.inspect(border) .. '})')

local caps = vim.lsp.protocol.make_client_capabilities()
caps.textDocument.completion.completionItem.snippetSupport = true
local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if ok then
  caps = cmp_nvim_lsp.update_capabilities(caps)
end

local M = {
  capabilities = caps,
}

function M.on_attach_lsp_document_highlight(client, _)
  if client.resolved_capabilities.document_highlight then
    vim.cmd([[aug LspShowReferences
        au! * <buffer>
        autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved,WinLeave <buffer> lua vim.lsp.buf.clear_references()
        aug END
      ]])
  end
end

function M.on_attach_lsp_document_formatting(client, _)
  local nmap = require('sh.keymap').nmap
  if client.resolved_capabilities.document_formatting then
    vim.cmd([[aug LspAutoformat
        au! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
        aug END
      ]])
    nmap({ '=', vim.lsp.buf.formatting })
  end
end

function M.on_attach_lsp_keymaps(_, bufnr)
  local nmap = require('sh.keymap').nmap
  local xmap = require('sh.keymap').xmap
  nmap({ 'gD', vim.lsp.buf.declaration, { silent = true, buffer = bufnr } })
  nmap({ 'gd', vim.lsp.buf.definition, { silent = true, buffer = bufnr } })
  nmap({ 'gi', vim.lsp.buf.implementation, { silent = true, buffer = bufnr } })
  nmap({ 'gr', vim.lsp.buf.references, { silent = true, buffer = bufnr } })
  nmap({ '[d', vim.diagnostic.goto_prev, { silent = true, buffer = bufnr } })
  nmap({ ']d', vim.diagnostic.goto_next, { silent = true, buffer = bufnr } })
  nmap({ 'gl', vim.lsp.buf.hover, { silent = true, buffer = bufnr } })
  nmap({ 'ga', vim.lsp.buf.code_action, { silent = true, buffer = bufnr } })
  xmap({ 'ga', vim.lsp.buf.range_code_action, { silent = true, buffer = bufnr } })
end

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

function M.common_on_attach(client, bufnr)
  for key, value in pairs(M) do
    if starts_with(key, 'on_attach') then
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

function M.configure_packer(use)
  use('antoinemadec/FixCursorHold.nvim')
  use('neovim/nvim-lspconfig')
  use('folke/lua-dev.nvim')
  use('nvim-lua/lsp-status.nvim')
  use({
    'hrsh7th/nvim-cmp',
    requires = {
      { 'hrsh7th/cmp-cmdline' },
      { 'andersevenrud/compe-tmux' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'hrsh7th/cmp-path' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'tamago324/cmp-zsh' },
      { 'lukas-reineke/cmp-under-comparator' },
      { 'lukas-reineke/cmp-rg' },
      { 'octaltree/cmp-look' },
    },
    config = function()
      local cmp = require('cmp')
      require('sh.gh_issues')
      local lspkind = require('lspkind')
      lspkind.init()
      cmp.setup({
        completion = { completeopt = 'menu,menuone,noselect' },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<C-y>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          ['<CR>'] = function(fallback)
            if cmp.visible() then
              return cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              })(fallback)
            else
              return fallback()
            end
          end,
          -- ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<c-n>'] = function(fallback)
            if cmp.visible() then
              return cmp.mapping.select_next_item({
                behavior = cmp.SelectBehavior.Insert,
              })(fallback)
            else
              return cmp.mapping.complete()(fallback)
            end
          end,
          -- ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Insert,
          }),
        },
        formatting = {
          format = lspkind.cmp_format({
            with_text = true,
            menu = {
              nvim_lua = '[nvim]',
              nvim_lsp = '[lsp]',
              emoji = '[emoji]',
              path = '[path]',
              calc = '[calc]',
              luasnip = '[snip]',
              buffer = '[buf]',
              gh_issues = '[issues]',
            },
          }),
        },
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            function(entry1, entry2)
              local _, entry1_under = entry1.completion_item.label:find('^_+')
              local _, entry2_under = entry2.completion_item.label:find('^_+')
              entry1_under = entry1_under or 0
              entry2_under = entry2_under or 0
              if entry1_under > entry2_under then
                return false
              elseif entry1_under < entry2_under then
                return true
              end
            end,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        window = { documentation = cmp.config.window.bordered() },
        sources = {
          { name = 'gh_issues' },
          { name = 'nvim_lua' },
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer', keyword_length = 5, max_item_count = 5 },
          {
            name = 'tmux',
            keyword_length = 3,
            max_item_count = 5,
            option = { all_panes = false },
          },
          -- {
          --   name = 'look',
          --   keyword_length = 5,
          --   max_item_count = 5,
          --   option = { convert_case = true, loud = true },
          -- },
          -- { name = 'zsh' },
          -- { name = 'calc' },
          -- { name = 'emoji' },
          -- { name = 'treesitter' },
          -- { name = 'crates' },
        },
        experimental = { native_menu = false, ghost_text = false },
      })
    end,
  })
  use('onsails/lspkind-nvim')
  use({
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup({})
    end,
  })
end

return M
