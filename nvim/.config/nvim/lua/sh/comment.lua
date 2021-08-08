local M = {}

function M.configure_packer(use)
  use {
    "terrortylor/nvim-comment",
    event = "BufRead",
    config = function()
      local status_ok, nvim_comment = pcall(require, "nvim_comment")
      if not status_ok then return end
      nvim_comment.setup()
    end
  }
end

return M
