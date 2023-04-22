return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      local nmap = require("sh.keymap").nmap
      nmap({
        "<leader>tt",
        function()
          require("neotest").run.run()
        end,
      })
      nmap({
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
      })
      nmap({
        "<leader>to",
        function()
          require("neotest").output_panel.toggle()
        end,
      })
    end,
  },
  { "nvim-neotest/neotest-python" },
  { "haydenmeade/neotest-jest" },
}
