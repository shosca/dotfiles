local M = {}

function M.configure_packer(use)
  use {"mfussenegger/nvim-dap", config = function() vim.fn.sign_define("DapBreakpoint", {text = '🛑', texthl = '', linehl = '', numhl = ''}) end}
  use {"mfussenegger/nvim-dap-python", requires = "mfussenegger/nvim-dap"}
  use {"rcarriga/nvim-dap-ui", requires = "mfussenegger/nvim-dap", config = function() require("dapui").setup() end}
end

return M
