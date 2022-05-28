local present, impatient = pcall(require, "impatient")
if present then
  impatient.enable_profile()
end

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
vim.g.do_filetype_lua = 1

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local backupdir = vim.fn.stdpath("data") .. "/backup"
local swapdir = vim.fn.stdpath("data") .. "/swap"
local undodir = vim.fn.stdpath("data") .. "/undo"
local shadadir = vim.fn.stdpath("data") .. "/shada"

vim.fn.mkdir(backupdir, "p")
vim.fn.mkdir(swapdir, "p")
vim.fn.mkdir(undodir, "p")
vim.fn.mkdir(shadadir, "p")

vim.schedule(function()
  vim.opt.shadafile = shadadir .. "/shada/main.shada"
  vim.cmd([[ silent! rsh ]])
end)

vim.opt.backupdir = backupdir
vim.opt.directory = swapdir
vim.opt.undodir = undodir

-- Ignore compiled files
vim.opt.wildmenu = true
vim.opt.wildoptions = "pum"
vim.opt.wildmode = { "longest", "full" }
vim.opt.wildchar = ("\t"):byte()
vim.opt.wildcharm = 26

vim.opt.wildignorecase = true
vim.opt.wildignore = { "__pycache__", "*.o", "*~", "*.pyc", "*pycache*" }

-- Cool floating window popup menu for completion on command line
vim.opt.pumblend = 17

vim.opt.showmode = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1 -- Height of the command bar
vim.opt.incsearch = true -- Makes search act like search in modern browsers
vim.opt.showmatch = true -- show matching brackets when text indicator is over them
vim.opt.relativenumber = true -- Show line numbers
vim.opt.number = true -- But show the actual number for the line we're on
vim.opt.ignorecase = true -- Ignore case when searching...
vim.opt.smartcase = true -- ... unless there is a capital letter in the query
vim.opt.hidden = true -- I like having buffers stay around
vim.opt.equalalways = true
vim.opt.splitright = true -- Prefer windows splitting to the right
vim.opt.splitbelow = true -- Prefer windows splitting to the bottom
vim.opt.updatetime = 300 -- Make updates happen faster
vim.opt.redrawtime = 10000 -- for syntax loading on large files
vim.opt.hlsearch = true -- I wouldn't use this without my DoNoHL function
vim.opt.scrolloff = 10 -- Make it so there are always ten lines below my cursor

-- Tabs
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.wrap = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.breakindent = true
vim.opt.showbreak = string.rep(" ", 3) -- Make it so that long lines wrap smartly
vim.opt.linebreak = true

vim.opt.foldmethod = "marker"
vim.opt.foldlevel = 3
vim.opt.modelines = 1

vim.opt.belloff = "all" -- Just turn the dang bell off

vim.opt.clipboard = "unnamedplus"

vim.opt.inccommand = "split"
vim.opt.shada = { "!", "'1000", "<50", "s10", "h" }

vim.opt.mouse = "n"
vim.opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "hiddenoff",
  "algorithm:minimal",
}

-- Helpful related items:
--   1. :center, :left, :right
--   2. gw{motion} - Put cursor back after formatting motion.
--
-- TODO: w, {v, b, l}
vim.opt.formatoptions = vim.opt.formatoptions
  - "a" -- Auto formatting is BAD.
  - "t" -- Don't auto format my code. I got linters for that.
  + "c" -- In general, I like it when comments respect textwidth
  + "q" -- Allow formatting comments w/ gq
  - "o" -- O and o, don't continue comments
  + "r" -- But do continue when pressing enter.
  + "n" -- Indent past the formatlistpat, not underneath it.
  + "j" -- Auto-remove comments if possible.
  - "2" -- I'm not in gradeschool anymore

-- set joinspaces
vim.opt.joinspaces = false -- Two spaces and grade school, we're done

-- set fillchars=eob:~
vim.opt.fillchars = { eob = "~" }

-- invisible characters to use on ':set list'
vim.opt.list = true
vim.opt.listchars = {
  tab = "› ",
  eol = "¬",
  nbsp = ".",
  trail = "•",
  extends = "#",
}

vim.cmd([[autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif]])

vim.opt.cursorline = true -- Highlight the current line
local group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
local set_cursorline = function(event, value, pattern)
  vim.api.nvim_create_autocmd(event, {
    group = group,
    pattern = pattern,
    callback = function()
      vim.opt_local.cursorline = value
    end,
  })
end
set_cursorline("WinLeave", false)
set_cursorline("WinEnter", true)
set_cursorline("FileType", false, "TelescopePrompt")

require("sh.filetypes")
require("sh.mappings")
require("sh.plugins")
