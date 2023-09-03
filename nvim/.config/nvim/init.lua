vim.loader.enable()

local utils = require("sh.utils")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local disabled_builtins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "man",
  "matchit",
  "matchparen",
  "netrw",
  "netrwFileHandlers",
  "netrwPlugin",
  "netrwSettings",
  "rrhelper",
  "spellfile_plugin",
  "tar",
  "tarPlugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
}
for _, v in pairs(disabled_builtins) do
  vim.g["loaded_" .. v] = 1
end

vim.g.python3_host_prog = "/usr/bin/python3"

require("sh.opts")
require("sh.autocmds")
require("sh.filetypes")
require("sh.mappings")
require("sh.lazy")
