local utils = require("sh.utils")

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim",
    },
    event = "VeryLazy",
    config = function()
      vim.o.winwidth = 20
      vim.o.winminwidth = 20
      vim.o.equalalways = true
      require("windows").setup()
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    keys = {
      {
        "<leader>sr",
        utils.bind("spectre", "open"),
        desc = "Replace in files (Spectre)",
      },
    },
  },
  {
    -- https://github.com/utilyre/barbecue.nvim
    -- Visual Studio Code inspired breadcrumbs plugin for the Neovim editor
    "utilyre/barbecue.nvim",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
  {
    -- https://github.com/hrsh7th/nvim-cmp
    -- A completion plugin for neovim coded in Lua.
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },
      { "hrsh7th/cmp-path" },
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      return {
        completion = { completeopt = "menu,menuone,noselect" },
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        mapping = {
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        },
        formatting = {
          format = function(entry, item)
            local icons = require("sh.ui").kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
        sorting = defaults.sorting,
        view = {
          entries = { follow_cursor = true },
        },
        window = { documentation = cmp.config.window.bordered() },
        sources = cmp.config.sources({
          { name = "nvim_lua" },
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        }),
        experimental = {
          native_menu = false,
          ghost_text = {

            hl_group = "CmpGhostText",
          },
        },
      }
    end,
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      require("cmp").setup(opts)
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    end,
  },
  {
    -- https://github.com/folke/noice.nvim
    -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
    "folke/noice.nvim",
    dependencies = {
      {
        -- https://github.com/MunifTanjim/nui.nvim
        -- UI Component Library for Neovim.
        "MunifTanjim/nui.nvim",
      },
    },
    opts = {
      notify = { enabled = false },
      lsp = {
        hover = {
          silent = true,
        },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          view = "mini",
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
        },
        {
          filter = {
            event = "msg_showmode",
          },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    },
  },
  {
    -- https://github.com/folke/snacks.nvim
    -- A collection of QoL plugins for Neovim
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      animake = {},
      dashboard = {},
      notifier = {},
      scroll = {},
      input = {},
      picker = {
        previewers = {
          diff = { builtin = false },
          git = { builtin = false },
        },
        win = {
          input = {
            keys = {
              ["<C-n>"] = { "history_forward", mode = { "i", "n" } },
              ["<C-p>"] = { "history_back", mode = { "i", "n" } },
            },
          },
        },
      },
      explorer = {},
      indent = {
        chunk = { enabled = true },
      },
      gitbrowse = {},
    },
    -- stylua: ignore
    keys = {
      { "<leader>bd",      function() Snacks.bufdelete() end,              desc = "Delete Buffer" },

      -- picker
      { "<leader><space>", function() Snacks.picker.smart() end,           desc = "Smart Find Files" },
      { "<leader>,",       function() Snacks.picker.buffers() end,         desc = "Buffers" },
      { "<leader>:",       function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>/",       function() Snacks.picker.grep() end,            desc = "Grep" },
      { "<leader>e",       function() Snacks.explorer() end,               desc = "File Explorer" },
      { "<leader>sg",      function() Snacks.picker.grep_word() end,       desc = "Visual selection or word", mode = { "n", "x" } },

      { "<leader>sk",      function() Snacks.picker.keymaps() end,         desc = "[s]earch [x]eymaps" },
      { "<leader>sd",      function() Snacks.picker.diagnostics() end,     desc = "[s]earch [d]iagnostics" },

      { "<leader>su",      function() Snacks.picker.undo() end,            desc = "Undo History" },
      { "<leader>ss",      function() Snacks.picker.resume() end,          desc = "Resume" },
      { "<leader>n",       function() Snacks.picker.notifications() end,   desc = "Notification History" },

      -- { "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
      -- find
      -- { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      -- { "<leader>ff",      function() Snacks.picker.files() end,                                   desc = "Find Files" },
      -- { "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
      -- { "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "Projects" },
      -- { "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent" },
      -- git
      -- { "<leader>gb",      function() Snacks.picker.git_branches() end,                            desc = "Git Branches" },
      -- { "<leader>gl",      function() Snacks.picker.git_log() end,                                 desc = "Git Log" },
      -- { "<leader>gL",      function() Snacks.picker.git_log_line() end,                            desc = "Git Log Line" },
      -- { "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "Git Status" },
      -- { "<leader>gS",      function() Snacks.picker.git_stash() end,                               desc = "Git Stash" },
      -- { "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
      -- { "<leader>gf",      function() Snacks.picker.git_log_file() end,                            desc = "Git Log File" },
      -- Grep
      -- { "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
      -- { "<leader>sB",      function() Snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
      -- { "<leader>sg",      function() Snacks.picker.grep() end,                                    desc = "Grep" },
      -- search
      -- { '<leader>s"',      function() Snacks.picker.registers() end,             desc = "Registers" },
      -- { '<leader>s/',      function() Snacks.picker.search_history() end,        desc = "Search History" },
      -- { "<leader>sa",      function() Snacks.picker.autocmds() end,              desc = "Autocmds" },
      -- { "<leader>sb",      function() Snacks.picker.lines() end,                 desc = "Buffer Lines" },
      -- { "<leader>sc",      function() Snacks.picker.command_history() end,       desc = "Command History" },
      -- { "<leader>sC",      function() Snacks.picker.commands() end,              desc = "Commands" },
      -- { "<leader>sd",      function() Snacks.picker.diagnostics() end,           desc = "Diagnostics" },
      -- { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,    desc = "Buffer Diagnostics" },
      -- { "<leader>sh",      function() Snacks.picker.help() end,                  desc = "Help Pages" },
      -- { "<leader>sH",      function() Snacks.picker.highlights() end,            desc = "Highlights" },
      -- { "<leader>si",      function() Snacks.picker.icons() end,                 desc = "Icons" },
      -- { "<leader>sj",      function() Snacks.picker.jumps() end,                 desc = "Jumps" },
      -- { "<leader>sl",      function() Snacks.picker.loclist() end,               desc = "Location List" },
      -- { "<leader>sm",      function() Snacks.picker.marks() end,                 desc = "Marks" },
      -- { "<leader>sM",      function() Snacks.picker.man() end,                   desc = "Man Pages" },
      -- { "<leader>sp",      function() Snacks.picker.lazy() end,                  desc = "Search for Plugin Spec" },
      -- { "<leader>sq",      function() Snacks.picker.qflist() end,                desc = "Quickfix List" },
      -- { "<leader>uC",      function() Snacks.picker.colorschemes() end,          desc = "Colorschemes" },
      -- LSP
      -- { "gd",              function() Snacks.picker.lsp_definitions() end,       desc = "Goto Definition" },
      -- { "gD",              function() Snacks.picker.lsp_declarations() end,      desc = "Goto Declaration" },
      -- { "gr",              function() Snacks.picker.lsp_references() end,        nowait = true,                     desc = "References" },
      -- { "gI",              function() Snacks.picker.lsp_implementations() end,   desc = "Goto Implementation" },
      -- { "gy",              function() Snacks.picker.lsp_type_definitions() end,  desc = "Goto T[y]pe Definition" },
      -- { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,           desc = "LSP Symbols" },
      -- { "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    },
  },
}
