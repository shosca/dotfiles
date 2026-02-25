return {
  {
    -- https://github.com/gsuuon/model.nvim
    "gsuuon/model.nvim",
    enabled = false,
    cmd = { "M", "Model", "Mchat" },
    init = function()
      vim.filetype.add({
        extension = {
          mchat = "mchat",
        },
      })
    end,
    ft = "mchat",
    config = function()
      require("model").setup({})
      require("model.providers.llamacpp").setup({
        binary = "/usr/bin/llama-server",
        models = "~/.cache/llama.cpp/",
      })
    end,
  },
  {
    -- https://github.com/ggml-org/llama.vim
    "ggml-org/llama.vim",
    -- enabled = false,
    -- init = function()
    --   vim.g.llama_config = {
    --     endpoint = "http://127.0.0.1:1234/v1/completions",
    --   }
    -- end,
  },
  {
    "NickvanDyke/opencode.nvim",
    keys = {
      {
        "<leader>aa",
        function()
          require("opencode").toggle()
        end,
        mode = { "n" },
        desc = "Toggle OpenCode",
      },
      {
        "<leader>as",
        function()
          require("opencode").select({ submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode select",
      },
      {
        "<leader>ai",
        function()
          require("opencode").ask("", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode ask",
      },
      {
        "<leader>aI",
        function()
          require("opencode").ask("@this: ", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode ask with context",
      },
      {
        "<leader>ab",
        function()
          require("opencode").ask("@file ", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode ask about buffer",
      },
      {
        "<leader>ap",
        function()
          require("opencode").prompt("@this", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode prompt",
      },
      -- Built-in prompts
      {
        "<leader>ape",
        function()
          require("opencode").prompt("explain", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode explain",
      },
      {
        "<leader>apf",
        function()
          require("opencode").prompt("fix", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode fix",
      },
      {
        "<leader>apd",
        function()
          require("opencode").prompt("diagnose", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode diagnose",
      },
      {
        "<leader>apr",
        function()
          require("opencode").prompt("review", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode review",
      },
      {
        "<leader>apt",
        function()
          require("opencode").prompt("test", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode test",
      },
      {
        "<leader>apo",
        function()
          require("opencode").prompt("optimize", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode optimize",
      },
    },
    init = function()
      vim.g.opencode_opts = {
        provider = {
          enabled = "wezterm",
          wezterm = {
            direction = "left",
          },
        },
      }
      vim.g.autoreload = true
    end,
    -- config = function()
    --   -- Recommended/example keymaps.
    --   vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end,
    --     { desc = "Ask opencode" })
    --   vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,
    --     { desc = "Execute opencode action…" })
    --   vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
    --
    --   vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
    --     { expr = true, desc = "Add range to opencode" })
    --   vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
    --     { expr = true, desc = "Add line to opencode" })
    --
    --   vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
    --     { desc = "opencode half page up" })
    --   vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
    --     { desc = "opencode half page down" })
    --
    --   -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
    --   vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
    --   vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    -- end,
  },
  {
    -- https://github.com/zbirenbaum/copilot.lua
    "zbirenbaum/copilot.lua",
    enabled = false,
    opts = {},
  },
  {
    -- https://github.com/milanglacier/minuet-ai.nvim
    "milanglacier/minuet-ai.nvim",
    enabled = false,
    opts = {},
  },
  {
    -- https://github.com/yetone/avante.nvim
    "yetone/avante.nvim",
    enabled = false,
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      provider = "ollama",
      providers = {
        ollama = {
          disable_tools = true,
          endpoint = "http://127.0.0.1:11434",
          -- model = "gemma3:latest",
          -- model = "qwen2.5-coder:14b",
          model = "qwen3:latest",
        },
      },
    },
  },
  {
    -- https://github.com/olimorris/codecompanion.nvim
    "olimorris/codecompanion.nvim",
    enabled = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
      },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "ollama",
          keymaps = {
            send = {
              modes = {
                n = { "<CR>" },
                i = nil,
              },
            },
            close = {
              modes = {
                n = "q",
                i = "<c-x>",
              },
            },
            stop = {
              modes = {
                n = "<c-x>",
              },
            },
          },
        },
        inline = {
          adapter = "ollama",
        },
        agent = {
          adapter = "ollama",
        },
      },
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = {
              model = {
                model = "qwen3:latest",
              },
            },
          })
        end,
      },
    },
  },
  {
    -- https://github.com/David-Kunz/gen.nvim
    "David-Kunz/gen.nvim",
    enabled = false,
    opts = {
      model = "qwen3:latest",
      display_mode = "vertical-split",
    },
  },
}
