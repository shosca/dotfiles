return {
  "mfussenegger/nvim-dap",
  dependencies = { "theHamsta/nvim-dap-virtual-text" },
  config = function()
    vim.fn.sign_define("DapBreakpoint", { text = "ß", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "ü", texthl = "", linehl = "", numhl = "" })

    local nmap = require("sh.keymap").nmap
    local dap = require("dap")
    nmap({ "<F5>", dap.continue, { silent = true } })
    nmap({ "<F10>", dap.step_over, { silent = true } })
    nmap({ "<F11>", dap.step_into, { silent = true } })
    nmap({ "<F12>", dap.step_out, { silent = true } })
    nmap({ "<leader>b", dap.toggle_breakpoint, { silent = true } })
    nmap({
      "<leader>B",
      function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      { silent = true },
    })
    nmap({
      "<leader>lp",
      function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end,
      { silent = true },
    })
    nmap({ "<leader>dr", dap.repl.open, { silent = true } })
    nmap({ "<leader>dl", dap.run_last, { silent = true } })
  end,
}