local utils = require("sh.utils")

return {
  {
    -- https://github.com/windwp/nvim-ts-autotag
    -- Use treesitter to auto close and auto rename html tag
    "windwp/nvim-ts-autotag",
    opts = {},
  },
  {
    "lincheney/nvim-ts-rainbow",
    opts = {},
  },
  {
    -- https://github.com/rhysd/committia.vim
    -- A Vim plugin for more pleasant editing on commit messages
    "rhysd/committia.vim",
  },
  {
    -- https://github.com/andythigpen/nvim-coverage
    -- Displays test coverage data in the sign column
    "andythigpen/nvim-coverage",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      auto_reload = true,
    },
    keys = {
      {
        "<leader>cc",
        utils.bind("coverage", "load", true),
        desc = "[C]overage toggle",
      },
    },
  },
  {
    -- https://github.com/sindrets/diffview.nvim
    -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    -- https://github.com/ruifm/gitlinker.nvim
    -- A lua neovim plugin to generate shareable file permalinks for several git web frontend hosts
    "ruifm/gitlinker.nvim",
    opts = {},
    keys = {
      {
        "<leader>gb",
        function()
          require("gitlinker").get_buf_range_url("n", {
            action_callback = require("gitlinker.actions").open_in_browser,
          })
        end,
        silent = true,
        desc = "Open line in github",
      },
    },
  },
  {
    -- https://github.com/lewis6991/gitsigns.nvim
    -- Git integration for buffers
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      --numhl = true,
      linehl = false,
      current_line_blame_opts = {
        delay = 2000,
        virt_text_pos = "eol",
      },
    },
  },
  {
    -- https://github.com/mfussenegger/nvim-dap
    -- Debug Adapter Protocol client implementation for Neovim
    "mfussenegger/nvim-dap",
    dependencies = { "theHamsta/nvim-dap-virtual-text" },
    keys = {
      { "<F5>", utils.bind("dap", "continue"), { silent = true } },
      { "<F10>", utils.bind("dap", "step_over"), { silent = true } },
      { "<F11>", utils.bind("dap", "step_into"), { silent = true } },
      { "<F12>", utils.bind("dap", "step_out"), { silent = true } },
      { "<leader>b", utils.bind("dap", "toggle_breakpoint"), { silent = true } },
      { "<leader>dl", utils.bind("dap", "rul_last"), { silent = true } },
      { "<leader>dr", utils.bind("dap.repl", "open"), { silent = true } },
    },
  },
  {
    -- https://github.com/rcarriga/nvim-dap-ui
    -- A UI for nvim-dap
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("dapui").eval(nil, { enter = true })
        end,
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    name = "dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
  },
  {
    -- https://github.com/folke/todo-comments.nvim
    -- Highlight, list and search todo comments in your projects
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    keys = {
      {
        "]t",
        utils.bind("todo-comments", "jump_next"),
        desc = "Next todo comment",
      },
      {
        "[t",
        utils.bind("todo-comments", "jump_prev"),
        desc = "Previous todo comment",
      },
      { "<leader>td", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        "luvit-meta/library",
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  { -- optional completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "olimorris/neotest-rspec",
      "haydenmeade/neotest-jest",
      "nvim-neotest/neotest-python",
    },
    keys = {
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run File",
      },
      {
        "<leader>tT",
        function()
          require("neotest").run.run(vim.loop.cwd())
        end,
        desc = "Run All Test Files",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.attach()
        end,
        desc = "Attach Output",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Show Output",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop",
      },
    },
    config = function()
      require("neotest").setup({
        termOpts = {
          direction = "horizontal",
        },
        adapters = {
          require("neotest-jest"),
          require("neotest-python"),
        },
      })
    end,
  },
  { "b0o/schemastore.nvim" },
}
