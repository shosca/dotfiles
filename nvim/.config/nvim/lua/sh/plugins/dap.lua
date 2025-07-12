local utils = require("sh.utils")

return {
  "mfussenegger/nvim-dap",
  dependencies = { "theHamsta/nvim-dap-virtual-text", "mfussenegger/nvim-dap-python" },
  keys = {
    { "<F5>", utils.bind("dap", "continue"), { silent = true } },
    { "<F10>", utils.bind("dap", "step_over"), { silent = true } },
    { "<F11>", utils.bind("dap", "step_into"), { silent = true } },
    { "<F12>", utils.bind("dap", "step_out"), { silent = true } },
    { "<leader>b", utils.bind("dap", "toggle_breakpoint"), { silent = true } },
    { "<leader>dl", utils.bind("dap", "rul_last"), { silent = true } },
    {
      "<leader>dr",
      function()
        require("dap").repl.open()
      end,
      { silent = true },
    },
  },
}
