local utils = require("sh.utils")

utils.set(vim.g, {
  mapleader = " ",
  maplocalleader = " ",
  python3_host_prog = "/usr/bin/python3",
  autoformat = true,
  markdown_recommended_style = 0,
})

utils.set(vim.opt, {
  ai = true,
  autoindent = true,
  autowrite = true,
  background = "dark",
  backup = true,
  backupdir = vim.fs.joinpath(vim.fn.stdpath("state"), "backup"),
  belloff = "all",
  breakindent = true,
  cindent = true,
  clipboard = "unnamedplus",
  cmdheight = 0, -- Height of the command bar
  conceallevel = 0,
  confirm = true,
  cursorline = true,
  fileencoding = "utf-8",
  diffopt = { "internal", "filler", "closeoff", "hiddenoff", "algorithm:minimal" },
  directory = vim.fs.joinpath(vim.fn.stdpath("state"), "swap"),
  equalalways = true,
  expandtab = true,
  exrc = true,
  fillchars = {
    foldopen = "",
    foldclose = "",
    fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = "~",
  },
  foldcolumn = "1",
  foldenable = true,
  foldlevel = 99,
  grepformat = "%f:%l:%c:%m",
  grepprg = "rg --vimgrep",
  hidden = true, -- I like having buffers stay around
  hlsearch = true, -- I wouldn't use this without my DoNoHL function
  ignorecase = true, -- Ignore case when searching...
  inccommand = "split",
  incsearch = true, -- Makes search act like search in modern browsers
  joinspaces = false, -- Two spaces and grade school, we're done
  laststatus = 3, -- Height of the command bar
  linebreak = true,
  list = true,
  listchars = {
    tab = "→―",
    eol = "¬",
    nbsp = "◇",
    trail = "·",
    extends = "▸",
    precedes = "◂",
    space = " ",
  },
  modelines = 1,
  --mouse = "nvi",
  mouse = "a",
  number = true,
  pumblend = 10,
  pumheight = 10,
  redrawtime = 10000,
  relativenumber = true,
  scrolloff = 4,
  sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
  shiftwidth = 2,
  showmode = false,
  signcolumn = "yes",
  smartcase = true,
  smartindent = true,
  splitbelow = true,
  splitright = true,
  tabstop = 2,
  termguicolors = true,
  timeoutlen = 300,
  undolevels = 10000,
  undodir = vim.fs.joinpath(vim.fn.stdpath("state"), "undo"),
  undofile = true,
  updatetime = 200, -- Save swap file and trigger CursorHold
  viewdir = vim.fs.joinpath(vim.fn.stdpath("state"), "view"),
  wildmenu = true,
  wildmode = { "longest", "full" },
  wildoptions = "pum",
  winminwidth = 5,
  wrap = false,
})
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })

vim.schedule(function()
  local shadadir = vim.fs.joinpath(vim.fn.stdpath("state"), "shada")
  utils.set(vim.opt, {
    shada = { "!", "'1000", "<50", "s10", "h" },
    shadafile = vim.fs.joinpath(shadadir, "main.shada"),
  })
  vim.cmd([[ silent! rsh ]])
end)

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
