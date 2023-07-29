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

local backupdir = vim.fn.stdpath("cache") .. "/backup"
local swapdir = vim.fn.stdpath("cache") .. "/swap"
local undodir = vim.fn.stdpath("cache") .. "/undo"
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
vim.opt.undofile = true

vim.opt.autowrite = true
vim.opt.clipboard = "unnamedplus"
vim.opt.conceallevel = 3
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.backup = true

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

vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

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

vim.opt.isfname:append("@-@")
vim.opt.showmode = false
vim.opt.showcmd = true
vim.opt.laststatus = 0 -- Height of the command bar
vim.opt.cmdheight = 0 -- Height of the command bar
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
vim.opt.updatetime = 1000 -- Make updates happen faster
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

vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.modelines = 1
vim.opt.exrc = true

vim.opt.belloff = "all" -- Just turn the dang bell off

vim.opt.inccommand = "split"
vim.opt.shada = { "!", "'1000", "<50", "s10", "h" }

vim.opt.mouse = "nvi"
vim.opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "hiddenoff",
  "algorithm:minimal",
}

-- set joinspaces
vim.opt.joinspaces = false -- Two spaces and grade school, we're done

vim.opt.fillchars = {
  eob = "~",
  foldopen = "",
  foldclose = "",
}

-- invisible characters to use on ':set list'
vim.opt.list = true
vim.opt.listchars = {
  tab = "→―",
  eol = "¬",
  nbsp = "◇",
  trail = "·",
  extends = "▸",
  precedes = "◂",
  space = " ",
}

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.laststatus = 3

vim.g.python3_host_prog = "/usr/bin/python3"

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd("FocusGained", { command = "checktime" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", { callback = vim.highlight.on_yank })

-- show cursor line only in active window
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  callback = function()
    local ok, cl = pcall(vim.api.nvim_win_get_var, 0, "auto-cursorline")
    if ok and cl then
      vim.wo.cursorline = true
      vim.api.nvim_win_del_var(0, "auto-cursorline")
    end
  end,
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  callback = function()
    local cl = vim.wo.cursorline
    if cl then
      vim.api.nvim_win_set_var(0, "auto-cursorline", cl)
      vim.wo.cursorline = false
    end
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*",
  callback = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "<buffer>",
      once = true,
      callback = function()
        vim.cmd(
          [[if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif]]
        )
      end,
    })
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "PlenaryTestPopup",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

require("sh.filetypes")
require("sh.mappings")
require("sh.lazy")
