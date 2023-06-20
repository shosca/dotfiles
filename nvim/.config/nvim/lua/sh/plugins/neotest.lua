return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-jest",
  },
  config = function()
    vim.keymap.set("n", "<leader>to", function()
      require("neotest").output_panel.toggle()
    end)
    vim.keymap.set("n", "<leader>tt", function()
      require("neotest").run.run()
      require("neotest").output_panel.open()
    end)
    vim.keymap.set("n", "<leader>tf", function()
      require("neotest").run.run(vim.fn.expand("%"))
      require("neotest").output_panel.open()
    end)
  end,
}
