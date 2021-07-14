local M = {}

local function config()
  vim.api.nvim_set_keymap("n", "<Leader>f", ":Telescope find_files<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<Leader>b", ":Telescope buffers<CR>", { noremap = true, silent = true })
end

function M.configure_packer(use)
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    config = config,
  }
end
return M
