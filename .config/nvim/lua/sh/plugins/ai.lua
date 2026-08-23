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
    "jhicks/sidekick.nvim",
    branch = "add-wezterm-as-mux-backend",
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
        mux = {
          enabled = true,
          backend = "wezterm",
          create = "split",
          split = {
            vertical = true,
            size = 0.5,
          },
        },
      },
    },
    config = function(_, opts)
      require("sidekick").setup(opts)
      -- Patch wezterm backend is_running: when the tool quits but the
      -- wezterm pane/shell stays open, the stock check kept returning
      -- true (it looked at the pane shell pid), so the session stayed
      -- "attached" and show/toggle/send became silent no-ops.
      local ok, Wezterm = pcall(require, "sidekick.cli.session.wezterm")
      if ok then
        local Util = require("sidekick.util")
        Wezterm.is_running = function(self)
          local pane_id = self.wezterm_pane_id
          if not pane_id then
            return false
          end
          local _, out = Util.exec({ "wezterm", "cli", "list", "--format", "json" }, { notify = false })
          local decoded, panes = pcall(vim.json.decode, out or "")
          if not decoded or type(panes) ~= "table" then
            return false
          end
          local tty
          for _, p in ipairs(panes) do
            if p.pane_id == pane_id then
              tty = p.tty_name
              break
            end
          end
          if not tty then
            return false -- pane is gone
          end
          local pid = Wezterm.root_pid(tty)
          if not pid then
            return false
          end
          local Procs = require("sidekick.cli.procs")
          local procs = Procs.new()
          local found = false
          procs:walk(pid, function(proc)
            if self.tool and self.tool:is_proc(proc) then
              found = true
              return true
            end
          end)
          return found
        end
      end
    end,
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
      {
        "<leader>ac",
        function()
          require("sidekick.cli").show({ name = "claude", focus = true })
        end,
        desc = "Sidekick attach claude",
      },
    },
  },
}
