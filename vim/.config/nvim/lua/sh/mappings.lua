local map = function(rhs, lhs) vim.api.nvim_set_keymap('', rhs, lhs, {}) end

local cmap = function(rhs, lhs) vim.api.nvim_set_keymap('c', rhs, lhs, {}) end

local nmap = function(rhs, lhs) vim.api.nvim_set_keymap('n', rhs, lhs, {}) end

local noremap = function(rhs, lhs)
    vim.api.nvim_set_keymap('', rhs, lhs, {noremap = true})
end

local cnoremap = function(rhs, lhs)
    vim.api.nvim_set_keymap('c', rhs, lhs, {noremap = true})
end

local inoremap = function(rhs, lhs)
    vim.api.nvim_set_keymap('i', rhs, lhs, {noremap = true})
end

local nnoremap = function(rhs, lhs)
    vim.api.nvim_set_keymap('n', rhs, lhs, {noremap = true})
end

local xnoremap = function(rhs, lhs)
    vim.api.nvim_set_keymap('x', rhs, lhs, {noremap = true})
end

local vnoremap = function(rhs, lhs)
    vim.api.nvim_set_keymap('v', rhs, lhs, {noremap = true})
end

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

-- Switch history search pairs, matching my bash shell
cnoremap('<C-p>', '<Up>')
cnoremap('<C-n>', '<Down>')
cnoremap('<Up>', '<C-p>')
cnoremap('<Down>', '<C-n>')

-- Fix keybind name for Ctrl+Spacebar
vim.cmd([[
map <Nul> <C-Space>
map! <Nul> <C-Space>
]])

-- In normal mode, jj escapes
inoremap('jj', '<Esc>')

-- buffers {
nnoremap('<Tab>', ':bnext<CR>')
nnoremap('<S-Tab>', ':bprevious<CR>')

-- split management {
nnoremap('sj', '<C-W>w<CR>')
nnoremap('sk', '<C-W>W<CR>')
nnoremap('ss', ':split<Space>')
nnoremap('sv', ':vsplit<Space>')

-- tab management {
nnoremap('th', ':tabfirst<CR>')
nnoremap('tj', ':tabnext<CR>')
nnoremap('tk', ':tabprev<CR>')
nnoremap('tl', ':tablast<CR>')
nnoremap('tt', ':tabedit<Space>')
nnoremap('tn', ':tabnext<CR>')
nnoremap('tm', ':tabm<Space>')
nnoremap('td', ':tabclose<CR>')

-- arrow key resize
nnoremap('<Up>', ':resize +2<CR>')
nnoremap('<Down>', ':resize -2<CR>')
nnoremap('<Left>', ':vertical resize +2<CR>')
nnoremap('<Right>', ':vertical resize -2<CR>')

-- Easier horizontal scrolling
map('zl', 'zL')
map('zh', 'zH')

-- Select blocks after indenting
xnoremap('<', '<gv')
xnoremap('>', '>gv|')

-- Use tab for indenting in visual mode
vnoremap('<Tab>', '>gv|')
vnoremap('<S-Tab>', '<gv')
-- nnoremap('>', '>>_')
-- nnoremap('<', '<<_')

-- Code folding options
nmap('<leader>f0', ':set foldlevel=0<CR>')
nmap('<leader>f1', ':set foldlevel=1<CR>')
nmap('<leader>f2', ':set foldlevel=2<CR>')
nmap('<leader>f3', ':set foldlevel=3<CR>')
nmap('<leader>f4', ':set foldlevel=4<CR>')
nmap('<leader>f5', ':set foldlevel=5<CR>')
nmap('<leader>f6', ':set foldlevel=6<CR>')
nmap('<leader>f7', ':set foldlevel=7<CR>')
nmap('<leader>f8', ':set foldlevel=8<CR>')
nmap('<leader>f9', ':set foldlevel=9<CR>')

-- Save a file with sudo
-- http://forrst.com/posts/Use_w_to_sudo_write_a_file_with_Vim-uAN
cmap('W!!', 'w !sudo tee % >/dev/null')
cmap('w!!', 'w !sudo tee % >/dev/null')
