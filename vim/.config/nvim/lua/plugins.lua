
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.api.nvim_command('packadd packer.nvim')
end

local packer = require('packer')

local packages = {
  'core',
  'theme',
  'treesitter',
  'telescope',
  'comment',
  --"compe",
  'lsp',
  'git',
}

packer.startup({
  function(use )
    use 'wbthomason/packer.nvim'
    for _, pkg in pairs(packages) do
      require(pkg).configure_packer(use)
    end

    use 'bfredl/nvim-luadev'
  end,
  config = {
    display = {
      open_fn = require('packer.util').float,
    }
  }
})
packer.install()
packer.compile()
