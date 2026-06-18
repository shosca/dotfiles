local utils = require("sh.utils")

return {
  {
    -- https://github.com/rhysd/committia.vim
    -- A Vim plugin for more pleasant editing on commit messages
    "rhysd/committia.vim",
  },
  {
    -- https://github.com/andythigpen/nvim-coverage
    -- Displays test coverage data in the sign column
    "andythigpen/nvim-coverage",
    cmd = { "CoverageShow", "CoverageHide", "CoverageLoad", "CoverageSummary" },
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
}
