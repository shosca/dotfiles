local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.api.nvim_command('packadd packer.nvim')
end

local packer = require('packer')

local packages = {'sh.ui', 'sh.core', 'sh.treesitter', 'sh.telescope', 'sh.comment', 'sh.lsp', 'sh.git', 'sh.dap', 'sh.luasnip'}

packer.startup({
  function(use)
    use 'wbthomason/packer.nvim'
    use {'lewis6991/impatient.nvim', rocks = 'mpack'}
    for _, pkg in pairs(packages) do require(pkg).configure_packer(use) end
  end,
  config = {
    compile_path = vim.fn.stdpath('config') .. '/lua/packer_compiled.lua',
    display = {open_fn = function() return require("packer.util").float {border = "rounded"} end}
  }
})
packer.install()
packer.compile()
