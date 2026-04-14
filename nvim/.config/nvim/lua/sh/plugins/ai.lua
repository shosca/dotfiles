local Wezterm = {}
function Wezterm:new(opts)
  setmetatable({}, self)
  self.__index = self
  self.opts = opts or {}
  self.pane_id = nil
  self.cmd = "opencode --port"
  return self
end

function Wezterm:focus_pane()
  if self.pane_id == nil then
    return nil
  end
  vim.fn.system(string.format("wezterm cli activate-pane --pane-id %d", self.pane_id))
end

function Wezterm:health()
  if vim.fn.executable("wezterm") ~= 1 then
    return "`wezterm` executable not found in `$PATH`.",
      {
        "Install `wezterm` and ensure it's in your `$PATH`.",
      }
  end

  if not vim.env.WEZTERM_PANE then
    return "Not running in a `wezterm` window.", {
      "Launch Neovim in a `wezterm` window.",
    }
  end

  return true
end

function Wezterm:get_pane_id()
  local ok = self:health()
  if ok ~= true then
    error(ok)
  end

  if self.pane_id == nil then
    return nil
  end

  local result = vim.fn.system("wezterm cli list --format json 2>&1")

  if result == nil or result == "" or result:match("error") then
    self.pane_id = nil
    return nil
  end

  local success, panes = pcall(vim.json.decode, result)
  if not success or type(panes) ~= "table" then
    self.pane_id = nil
    return nil
  end

  for _, pane in ipairs(panes) do
    if tostring(pane.pane_id) == tostring(self.pane_id) then
      return self.pane_id
    end
  end

  -- Pane was not found in the list
  self.pane_id = nil
  return nil
end

function Wezterm:toggle()
  local pane_id = self.get_pane_id(self)
  if pane_id then
    self:stop()
  else
    self:start()
  end
end

function Wezterm:start()
  local pane_id = self:get_pane_id()
  if not pane_id then
    local cmd_parts = { "wezterm", "cli", "split-pane" }

    if self.opts.direction then
      table.insert(cmd_parts, "--" .. self.opts.direction)
    end

    if self.opts.percent then
      table.insert(cmd_parts, "--percent")
      table.insert(cmd_parts, tostring(self.opts.percent))
    end

    if self.opts.top_level then
      table.insert(cmd_parts, "--top-level")
    end

    table.insert(cmd_parts, "--")
    table.insert(cmd_parts, self.cmd)

    local result = vim.fn.system(table.concat(cmd_parts, " "))
    self:focus_pane()

    self.pane_id = result:match("^%d+")
  end
end

---Kill the `opencode` pane.
function Wezterm:stop()
  local pane_id = self:get_pane_id()
  if pane_id then
    vim.fn.system(string.format("wezterm cli kill-pane --pane-id %d", pane_id))
    self.pane_id = nil
  end
end

return {
  {
    -- https://github.com/ggml-org/llama.vim
    "ggml-org/llama.vim",
    enabled = false,
    -- init = function()
    --   vim.g.llama_config = {
    --     endpoint = "http://127.0.0.1:1234/v1/completions",
    --   }
    -- end,
  },
  -- {
  --   "sudo-tee/opencode.nvim",
  --   dependencies = {
  --     "MeanderingProgrammer/render-markdown.nvim",
  --     "hrsh7th/nvim-cmp",
  --     "folke/snacks.nvim",
  --   },
  --   config = function()
  --     require("opencode").setup({})
  --   end,
  -- },
  {
    "folke/sidekick.nvim",
    enabled = false,
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
        desc = "Sidekick SelectlPrompt",
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
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
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
  {
    -- https://github.com/NickvanDyke/opencode.nvim
    "NickvanDyke/opencode.nvim",
    --enabled = false,
    init = function()
      local w = Wezterm:new({
        direction = "right",
        percent = 25,
      })
      vim.g.opencode_opts = {
        server = {
          start = function()
            w:start()
          end,
          stop = function()
            w:stop()
          end,
          toggle = function()
            w:toggle()
          end,
        },
      }
      vim.g.autoreload = true
      vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
          w:stop()
        end,
      })
    end,
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
          require("opencode").ask("@this: ", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode ask",
      },
      {
        "<leader>aI",
        function()
          require("opencode").ask("", { submit = true })
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
  },
}
