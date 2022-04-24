local nmap = require('sh.keymap').nmap
local imap = require('sh.keymap').nmap
local vmap = require('sh.keymap').vmap
local cmap = require('sh.keymap').cmap
local xmap = require('sh.keymap').xmap

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

nmap({ '*', ":let @/='\\<<c-r><c-w>\\>'<CR>:set hls<CR>", { silent = true } })

nmap({ 'Y', 'yg$' })
nmap({ 'n', 'nzzzv' })
nmap({ 'N', 'Nzzzv' })
nmap({ 'J', 'mzJ`z' })
-- Switch history search pairs, matching my bash shell
for _, c in ipairs({ '.', '_', ',', '!', '?' }) do
  imap({ c, string.format('%s<c-g>u', c) })
end
vmap({ 'J', ":m '>+1<CR>gv=gv" })
vmap({ 'K', ":m '<-2<CR>gv=gv" })

cmap({ '<C-p>', '<Up>' })
cmap({ '<C-n>', '<Down>' })
cmap({ '<Up>', '<C-p>' })
cmap({ '<Down>', '<C-n>' })

-- buffers {
nmap({ '<Tab>', ':bnext<CR>' })
nmap({ '<S-Tab>', ':bprevious<CR>' })

-- split management {
nmap({ 'sj', '<C-W>w<CR>' })
nmap({ 'sk', '<C-W>W<CR>' })
nmap({ 'ss', ':split<Space>' })
nmap({ 'sv', ':vsplit<Space>' })

-- arrow key resize
nmap({ '<Up>', ':resize +2<CR>' })
nmap({ '<Down>', ':resize -2<CR>' })
nmap({ '<Left>', ':vertical resize +2<CR>' })
nmap({ '<Right>', ':vertical resize -2<CR>' })

-- Easier horizontal scrolling
nmap({ 'zl', 'zL' })
nmap({ 'zh', 'zH' })

-- Select blocks after indenting
xmap({ '<', '<gv' })
xmap({ '>', '>gv|' })

-- Use tab for indenting in visual mode
vmap({ '<Tab>', '>gv|' })
vmap({ '<S-Tab>', '<gv' })
-- nnoremap('>', '>>_')
-- nnoremap('<', '<<_')

-- Code folding options

nmap({ '<leader>f0', ':set foldlevel=0<CR>' })
nmap({ '<leader>f1', ':set foldlevel=1<CR>' })
nmap({ '<leader>f2', ':set foldlevel=2<CR>' })
nmap({ '<leader>f3', ':set foldlevel=3<CR>' })
nmap({ '<leader>f4', ':set foldlevel=4<CR>' })
nmap({ '<leader>f5', ':set foldlevel=5<CR>' })
nmap({ '<leader>f6', ':set foldlevel=6<CR>' })
nmap({ '<leader>f7', ':set foldlevel=7<CR>' })
nmap({ '<leader>f8', ':set foldlevel=8<CR>' })
nmap({ '<leader>f9', ':set foldlevel=9999<CR>' })
