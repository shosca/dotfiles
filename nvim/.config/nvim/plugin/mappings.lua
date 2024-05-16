-- common typos
vim.cmd([[
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qa! qa!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qa qa
cnoreabbrev Qall qall
]])

vim.keymap.set("n", "*", ":let @/='\\<<c-r><c-w>\\>'<CR>:set hls<CR>", { silent = true })

vim.keymap.set("n", "Y", "yg$")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "J", "mzJ`z")
-- Switch history search pairs, matching my bash shell
for _, c in ipairs({ ".", "_", ",", "!", "?" }) do
  vim.keymap.set("i", c, string.format("%s<c-g>u", c))
end
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("c", "<C-p>", "<Up>")
vim.keymap.set("c", "<C-n>", "<Down>")
vim.keymap.set("c", "<Up>", "<C-p>")
vim.keymap.set("c", "<Down>", "<C-n>")

-- split management {
vim.keymap.set("n", "sj", "<C-W>w<CR>")
vim.keymap.set("n", "sk", "<C-W>W<CR>")
vim.keymap.set("n", "ss", ":split<Space>")
vim.keymap.set("n", "sv", ":vsplit<Space>")

-- arrow key resize
vim.keymap.set("n", "<Up>", ":resize +2<CR>")
vim.keymap.set("n", "<Down>", ":resize -2<CR>")
vim.keymap.set("n", "<Left>", ":vertical resize +2<CR>")
vim.keymap.set("n", "<Right>", ":vertical resize -2<CR>")

-- Easier horizontal scrolling
vim.keymap.set("n", "zl", "zL")
vim.keymap.set("n", "zh", "zH")

-- Select blocks after indenting
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv|")

-- Use tab for indenting in visual mode
vim.keymap.set("v", "<Tab>", ">gv|")
vim.keymap.set("v", "<S-Tab>", "<gv")
