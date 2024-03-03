local utils = require("sh.utils")

local opts = {
  ai = true,
  autoindent = true,
  autowrite = true,
  background = "dark",
  backup = true,
  backupdir = utils.path_join(vim.fn.stdpath("state"), "backup"),
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
  directory = utils.path_join(vim.fn.stdpath("state"), "swap"),
  equalalways = true,
  expandtab = true,
  exrc = true,
  fillchars = { eob = "~", foldopen = "", foldclose = "" },
  foldcolumn = "1",
  foldenable = true,
  foldlevel = 9,
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
  mouse = "a", -- allow the mouse to be used in neovim
  number = true, -- But show the actual number for the line we're on
  pumblend = 10, -- Cool floating window popup menu for completion on command line
  pumheight = 10,
  redrawtime = 10000, -- for syntax loading on large files
  relativenumber = true, -- Show line numbers
  scrolloff = 10, -- Make it so there are always ten lines below my cursor
  shiftwidth = 4,
  showbreak = string.rep(" ", 3), -- Make it so that long lines wrap smartly
  showcmd = true,
  showmatch = true, -- show matching brackets when text indicator is over them
  showmode = false,
  signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
  smartcase = true, -- ... unless there is a capital letter in the query
  smartindent = true,
  smarttab = true,
  softtabstop = 4,
  splitbelow = true, -- Prefer windows splitting to the bottom
  splitright = true, -- Prefer windows splitting to the right
  tabstop = 4,
  termguicolors = true,
  timeout = true,
  timeoutlen = 300,
  undodir = utils.path_join(vim.fn.stdpath("state"), "undo"),
  undofile = true,
  updatetime = 250,
  viewdir = utils.path_join(vim.fn.stdpath("state"), "view"),
  wildchar = ("\t"):byte(),
  wildcharm = 26,
  wildignore = { "__pycache__", "*.o", "*~", "*.pyc", "*pycache*" },
  wildignorecase = true,
  wildmenu = true,
  wildmode = { "longest", "full" },
  wildoptions = "pum",
  wrap = false,
}

for k, v in pairs(opts) do
  vim.opt[k] = v
end

vim.schedule(function()
  local shadadir = utils.path_join(vim.fn.stdpath("state"), "shada")
  vim.opt.shada = { "!", "'1000", "<50", "s10", "h" }
  vim.opt.shadafile = utils.path_join(shadadir, "main.shada")
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
