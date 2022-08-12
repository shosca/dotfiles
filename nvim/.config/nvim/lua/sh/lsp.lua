local ui = require("sh.ui")

vim.lsp.handlers["textDocument/definition"] = function(_, result)
  if not result or vim.tbl_isempty(result) then
    print("[LSP] Could not find definition")
    return
  end

  if vim.tbl_islist(result) then
    vim.lsp.util.jump_to_location(result[1], "utf-8")
  else
    vim.lsp.util.jump_to_location(result, "utf-8")
  end
end
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = ui.borders })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = ui.borders })

local caps = vim.lsp.protocol.make_client_capabilities()
caps.textDocument.completion.completionItem.snippetSupport = true
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  caps = cmp_nvim_lsp.update_capabilities(caps)
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
      group = au_lsp_doc_highlight,
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
      callback = vim.lsp.buf.format,
    })
  end
end

function M.on_attach_lsp_keymaps(_, bufnr)
  local nmap = require("sh.keymap").nmap
  local xmap = require("sh.keymap").xmap
  nmap({ "gD", vim.lsp.buf.declaration, { silent = true, buffer = bufnr } })
  nmap({ "gd", vim.lsp.buf.definition, { silent = true, buffer = bufnr } })
  nmap({ "gi", vim.lsp.buf.implementation, { silent = true, buffer = bufnr } })
  nmap({ "gf", vim.lsp.buf.format, { silent = true, buffer = bufnr } })
  nmap({ "gr", vim.lsp.buf.references, { silent = true, buffer = bufnr } })
  nmap({ "gl", vim.lsp.buf.hover, { silent = true, buffer = bufnr } })
  nmap({ "gk", vim.lsp.buf.signature_help, { silent = true, buffer = bufnr } })
  nmap({ "ga", vim.lsp.buf.code_action, { silent = true, buffer = bufnr } })
  xmap({ "la", vim.lsp.buf.range_code_action, { silent = true, buffer = bufnr } })
  nmap({ "[d", vim.diagnostic.goto_prev, { silent = true, buffer = bufnr } })
  nmap({ "]d", vim.diagnostic.goto_next, { silent = true, buffer = bufnr } })
end

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

function M.common_on_attach(client, bufnr)
  for key, value in pairs(M) do
    if starts_with(key, "on_attach") then
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
  use("antoinemadec/FixCursorHold.nvim")
  use("neovim/nvim-lspconfig")
  use("folke/lua-dev.nvim")
  use("nvim-lua/lsp-status.nvim")
  -- use({
  --   "glepnir/lspsaga.nvim",
  --   branch = "main",
  --   config = function()
  --       local saga = require("lspsaga")
  --       saga.init_lsp_saga({
  --         symbol_in_winbar = {
  --           enable = true,
  --         }
  --       })
  --   end,
  -- })
  use({
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local nullls = require("null-ls")
      nullls.setup({
        debounce = 600,
        sources = {
          nullls.builtins.code_actions.gitrebase,
          nullls.builtins.code_actions.gitsigns,

          nullls.builtins.diagnostics.eslint_d,
          nullls.builtins.code_actions.eslint_d,

          nullls.builtins.formatting.shfmt.with({
            extra_args = {
              "-i",
              "4", -- 4 spaces
              "-ci", -- indent switch cases
              "-sr", -- redirect operators are followed by space
              "-bn", -- binary ops like && or | (pipe) start the line
            },
          }),

          nullls.builtins.formatting.terraform_fmt.with({
            filetypes = { "hcl", "terraform" },
          }),
        },
      })
    end,
  })
  use({
    "hrsh7th/nvim-cmp",
    requires = {
      { "hrsh7th/cmp-cmdline" },
      { "andersevenrud/compe-tmux" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lsp-document-symbol" },
      { "hrsh7th/cmp-nvim-lua" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "tamago324/cmp-zsh" },
      { "lukas-reineke/cmp-under-comparator" },
      { "lukas-reineke/cmp-rg" },
      { "octaltree/cmp-look" },
    },
    config = function()
      local cmp = require("cmp")
      require("sh.gh_issues")
      local lspkind = require("lspkind")
      lspkind.init()
      cmp.setup({
        completion = { completeopt = "menu,menuone,noselect" },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<C-y>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          ["<CR>"] = function(fallback)
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
          ["<c-n>"] = function(fallback)
            if cmp.visible() then
              return cmp.mapping.select_next_item({
                behavior = cmp.SelectBehavior.Insert,
              })(fallback)
            else
              return cmp.mapping.complete()(fallback)
            end
          end,
          -- ['<C-p>'] = cmp.mapping.select_prev_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Insert,
          }),
        },
        formatting = {
          format = function(entry, vim_item)
            local opts = {
              menu = {
                nvim_lua = "nvim",
                nvim_lsp = "lsp",
                emoji = "emoji",
                path = "path",
                calc = "calc",
                luasnip = "snip",
                buffer = "buf",
                gh_issues = "issues",
              },
            }
            if entry.completion_item.detail ~= nil and entry.completion_item.detail ~= "" then
              opts.menu.nvim_lsp = entry.completion_item.detail
            end
            return lspkind.cmp_format(opts)(entry, vim_item)
          end,
        },
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            function(entry1, entry2)
              local _, entry1_under = entry1.completion_item.label:find("^_+")
              local _, entry2_under = entry2.completion_item.label:find("^_+")
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
          { name = "gh_issues" },
          { name = "nvim_lua" },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer", keyword_length = 5, max_item_count = 5 },
          {
            name = "tmux",
            keyword_length = 3,
            max_item_count = 5,
            option = { all_panes = false },
          },
          {
            name = "look",
            keyword_length = 2,
            max_item_count = 5,
            option = { convert_case = true, loud = true },
          },
          -- { name = 'zsh' },
          -- { name = 'calc' },
          -- { name = 'emoji' },
          -- { name = 'treesitter' },
          -- { name = 'crates' },
        },
        experimental = { native_menu = false, ghost_text = true },
      })
    end,
  })
  use("onsails/lspkind-nvim")
  use({
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({})
    end,
  })
  use({
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
    end,
  })
end

return M
