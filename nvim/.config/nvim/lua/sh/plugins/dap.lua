return {
  "mfussenegger/nvim-dap",
  dependencies = { "theHamsta/nvim-dap-virtual-text", "mfussenegger/nvim-dap-python" },
  config = function()
    vim.fn.sign_define("DapBreakpoint", { text = "ß", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "ü", texthl = "", linehl = "", numhl = "" })

    local dap = require("dap")
    vim.keymap.set("n", "<F5>", dap.continue, { silent = true })
    vim.keymap.set("n", "<F10>", dap.step_over, { silent = true })
    vim.keymap.set("n", "<F11>", dap.step_into, { silent = true })
    vim.keymap.set("n", "<F12>", dap.step_out, { silent = true })
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { silent = true })
    vim.keymap.set("n", "<leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { silent = true })
    vim.keymap.set("n", "<leader>lp", function()
      dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end, { silent = true })
    vim.keymap.set("n", "<leader>dr", dap.repl.open, { silent = true })
    vim.keymap.set("n", "<leader>dl", dap.run_last, { silent = true })
  end,
}
