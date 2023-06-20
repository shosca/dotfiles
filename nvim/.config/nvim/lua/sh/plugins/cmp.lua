return {
  "hrsh7th/nvim-cmp",
  dependencies = {
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
    { "onsails/lspkind-nvim" },
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
        { name = "copilot" },
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
}
