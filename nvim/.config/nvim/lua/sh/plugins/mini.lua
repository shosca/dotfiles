return {
  --{ "echasnovski/mini.animate", opts = {} },
  { "echasnovski/mini.align", opts = {} },
  { "echasnovski/mini.basics", opts = {} },
  -- {
  --   "echasnovski/mini.notify",
  --   opts = {
  --     lsp_progress = { enable = true },
  --     window = {
  --       anchor = "NE",
  --       relative = "win",
  --     },
  --   },
  -- },
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          require("mini.bufremove").delete(0, false)
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>bD",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete Buffer (Force)",
      },
    },
  },
  { "echasnovski/mini.indentscope", opts = {} },
  { "echasnovski/mini.hipatterns", opts = {} },
  {
    "echasnovski/mini.files",
    opts = {},
    keys = {
      {
        "<leader>mo",
        function()
          require("mini.files").open()
        end,
        desc = "Minifiles open",
      },
    },
  },
  { "echasnovski/mini.move", opts = {} },
  { "echasnovski/mini.operators", opts = {} },
  { "echasnovski/mini.pairs", opts = {} },
  {
    "echasnovski/mini.starter",
    event = "VimEnter",
    opts = function()
      local new_section = function(name, action, section)
        return { name = name, action = action, section = " " .. section }
      end

      return {
        header = table.concat({
          "      ,l;             c,      ",
          "   .:ooool'           loo:.   ",
          " .,oooooooo:.         looooc, ",
          "l:,loooooooool,       looooool",
          "llll,;ooooooooc.      looooooo",
          "lllllc,coooooooo;     looooooo",
          "lllllll;,loooooool'   looooooo",
          "lllllllc .:oooooooo:. looooooo",
          "lllllllc   'loooooool,:ooooooo",
          "lllllllc     ;ooooooooc,cooooo",
          "lllllllc      .coooooooo;;looo",
          "lllllllc        ,loooooool,:ol",
          " 'cllllc         .:oooooooo;. ",
          "   .;llc           .loooo:.   ",
          "      ,;             ;l;      ",
          "                              ",
        }, "\n"),
        evaluate_single = true,
        items = {
          new_section("Find file", "Telescope find_files", "Telescope"),
          new_section("Recent files", "Telescope oldfiles", "Telescope"),
          new_section("Grep text", "Telescope live_grep", "Telescope"),
          new_section("Lazy", "Lazy", "Config"),
          new_section("New file", "ene | startinsert", "Built-in"),
          new_section("Quit", "qa", "Built-in"),
        },
      }
    end,
  },
  {
    "echasnovski/mini.statusline",
    config = function()
      local m = require("mini.statusline")
      m.setup({
        content = {
          active = function()
            local mode, mode_hl = m.section_mode({ trunc_width = 120 })
            local spell = vim.wo.spell and (m.is_truncated(120) and "S" or "SPELL") or ""
            local wrap = vim.wo.wrap and (m.is_truncated(120) and "W" or "WRAP") or ""
            local git = m.section_git({ trunc_width = 75 })
            local diagnostics = m.section_diagnostics({ trunc_width = 75 })
            local filename = m.section_filename({ trunc_width = 140 })
            local fileinfo = m.section_fileinfo({ trunc_width = 120 })
            local searchcount = m.section_searchcount({ trunc_width = 75 })
            local location = m.section_location({ trunc_width = 75 })
            return m.combine_groups({
              { hl = mode_hl, strings = { mode, spell, wrap } },
              { hl = "MiniStatuslineDevinfo", strings = { diagnostics } },
              "%<", -- Mark general truncate point
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=", -- End left alignment
              { hl = mode_hl, strings = { git } },
              { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
              { hl = mode_hl, strings = { searchcount, location } },
            })
          end,
        },
      })
    end,
  },
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "gza", -- Add surrounding in Normal and Visual modes
        delete = "gzd", -- Delete surrounding
        find = "gzf", -- Find surrounding (to the right)
        find_left = "gzF", -- Find surrounding (to the left)
        highlight = "gzh", -- Highlight surrounding
        replace = "gzr", -- Replace surrounding
        update_n_lines = "gzn", -- Update `n_lines`
      },
    },
  },
  { "echasnovski/mini.trailspace", opts = {} },
}
