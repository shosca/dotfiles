return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "olimorris/neotest-rspec",
    "haydenmeade/neotest-jest",
    "nvim-neotest/neotest-python",
  },
  config = function()
    require("neotest").setup({
      termOpts = {
        direction = "horizontal",
      },
      adapters = {
        require("neotest-jest"),
        require("neotest-python"),
      },
    })
  end,
}
