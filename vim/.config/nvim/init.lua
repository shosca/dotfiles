vim.g.loaded_matchparen = 1
vim.g.loaded_zipPlugin= 1
vim.g.loaded_zip = 1

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Ignore compiled files
vim.opt.wildignorecase = true
vim.opt.wildignore = {
    "__pycache__",
    "*.o",
    "*~",
    "*.pyc",
    "*pycache*"
}

vim.opt.wildmode = { "longest", "list", "full" }

-- Cool floating window popup menu for completion on command line
vim.opt.pumblend = 17

vim.opt.wildmode = vim.opt.wildmode - "list"
vim.opt.wildmode = vim.opt.wildmode + { "longest", "full" }

vim.opt.wildoptions = "pum"

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
vim.opt.cursorline = true -- Highlight the current line
vim.opt.equalalways = true
vim.opt.splitright = true -- Prefer windows splitting to the right
vim.opt.splitbelow = true -- Prefer windows splitting to the bottom
vim.opt.updatetime = 1000 -- Make updates happen faster
vim.opt.hlsearch = true -- I wouldn't use this without my DoNoHL function
vim.opt.scrolloff = 10 -- Make it so there are always ten lines below my cursor

-- Tabs
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.wrap = true

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
vim.opt.swapfile = false -- Living on the edge
vim.opt.shada = { "!", "'1000", "<50", "s10", "h" }

vim.opt.mouse = "n"

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
  tab       = '› '  ,
  eol       = '↲'   ,
  nbsp      = '.'   ,
  trail     = '•'   ,
  extends   = '#'   ,
}

require 'sh.filetypes'
require 'sh.mappings'
require 'sh.plugins'
