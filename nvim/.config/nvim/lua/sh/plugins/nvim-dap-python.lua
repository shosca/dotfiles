return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap" },
  config = function()
    require("dap-python").setup()
  end,
}
