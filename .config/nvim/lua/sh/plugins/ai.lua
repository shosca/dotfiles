return {
  {
    "cajames/copy-reference.nvim",
    opts = {}, -- optional configuration
    keys = {
      { "yr", "<cmd>CopyReference file<cr>", mode = { "n", "v" }, desc = "Copy file path" },
      { "yrr", "<cmd>CopyReference line<cr>", mode = { "n", "v" }, desc = "Copy file:line reference" },
    },
  },
  {
    "folke/sidekick.nvim",
    opts = {
      win = {
        split = {
          width = 80,
        },
      },
      cli = {
        tools = {
          kilo = {
            cmd = { "kilo" },
          },
          omp = {
            cmd = { "omp" },
            resume = { "--resume" },
            continue = { "--continue" },
            native_scroll = false,
          },
        },
        prompts = {
          diagnostics = "Can you help me fix the diagnostics in {file}?\n{diagnostics}",
          diagnostics_all = "Can you help me fix these diagnostics?\n{diagnostics_all}",
          changes = "Can you review my changes?",
          document = "Add documentation to {function|line}",
          explain = "Explain {this}",
          fix = "Can you fix {this}?",
          optimize = "How can {this} be optimized?",
          review = "Can you review {file} for any issues or improvements?",
          tests = "Can you write tests for {this}?",
          -- simple context prompts
          buffers = "{buffers}",
          file = "{file}",
          line = "{line}",
          position = "{position}",
          quickfix = "{quickfix}",
          selection = "{selection}",
          ["function"] = "{function}",
          class = "{class}",
        },
        win = {
          keys = {
            escape = { "<Esc>", "<c-[>", mode = "t" },
          },
        },
      },
    },
    keys = {
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        mode = { "n" },
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>ai",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Sidekick Send file",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Sidekick Send visual selection content",
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").send({ msg = "{diagnostics}" })
        end,
        mode = { "x" },
        desc = "Sidekick Send selected diagnostics",
      },
      {
        "<leader>ao",
        function()
          require("sidekick.cli").toggle({ name = "opencode", focus = true })
        end,
        desc = "Sidekick toggle opencode",
      },
    },
  },
}
