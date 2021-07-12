local M = {}

function M.setup()
  vim.opt.termguicolors = true
  vim.opt.background = 'dark'

  vim.g.material_style = 'deep ocean'
  vim.g.material_italic_comments = true
  vim.g.material_italic_keywords = true
  vim.g.material_italic_functions = true
  vim.g.material_italic_variables = false
  vim.g.material_contrast = true
  vim.g.material_borders = false
  vim.g.material_disable_background = false
end

function M.config()
  require('material').set()
end

function M.configure_packer(use)
  use {
    'marko-cerovac/material.nvim',
    setup = M.setup,
    config = M.config,
  }
end
return M
