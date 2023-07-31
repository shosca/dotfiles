local utils = require("sh.utils")

local lazypath = utils.path_join(vim.fn.stdpath("data"), "lazy", "lazy.nvim")
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("sh.plugins", {
  ui = {
    icons = require("sh.ui").icons,
  },
})
