local setup = function()
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

local config = function()
  require('material').set()
end

return {
  configure_packer = function(use)
    use {
      'marko-cerovac/material.nvim',
      setup = setup,
      config = config,
    }
  end
}
