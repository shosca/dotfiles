local ok, _ = pcall(require, "astronauta.keymap")
if ok then

  local map = vim.keymap.map
  local nmap = vim.keymap.nmap
  local cmap = vim.keymap.cmap
  local nnoremap = vim.keymap.nnoremap
  local inoremap = vim.keymap.inoremap
  local cnoremap = vim.keymap.cnoremap
  local xnoremap = vim.keymap.xnoremap
  local vnoremap = vim.keymap.vnoremap

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

  nnoremap {"*", ":let @/='\\<<c-r><c-w>\\>'<CR>:set hls<CR>", silent = true}

  nnoremap {"Y", "yg$"}
  nnoremap {"n", "nzzzv"}
  nnoremap {"N", "Nzzzv"}
  nnoremap {"J", "mzJ`z"}
  -- Switch history search pairs, matching my bash shell
  for _, c in ipairs({".", "_", ",", "!", "?"}) do inoremap {c, string.format("%s<c-g>u", c)} end
  vnoremap {"J", ":m '>+1<CR>gv=gv"}
  vnoremap {"K", ":m '<-2<CR>gv=gv"}

  cnoremap {"<C-p>", "<Up>"}
  cnoremap {'<C-n>', '<Down>'}
  cnoremap {'<Up>', '<C-p>'}
  cnoremap {'<Down>', '<C-n>'}

  -- In normal mode, jj escapes
  inoremap {'jj', '<Esc>'}

  -- buffers {
  nnoremap {'<Tab>', ':bnext<CR>'}
  nnoremap {'<S-Tab>', ':bprevious<CR>'}

  -- split management {
  nnoremap {'sj', '<C-W>w<CR>'}
  nnoremap {'sk', '<C-W>W<CR>'}
  nnoremap {'ss', ':split<Space>'}
  nnoremap {'sv', ':vsplit<Space>'}

  -- arrow key resize
  nnoremap {'<Up>', ':resize +2<CR>'}
  nnoremap {'<Down>', ':resize -2<CR>'}
  nnoremap {'<Left>', ':vertical resize +2<CR>'}
  nnoremap {'<Right>', ':vertical resize -2<CR>'}

  -- Easier horizontal scrolling
  map {'zl', 'zL'}
  map {'zh', 'zH'}

  -- Select blocks after indenting
  xnoremap {'<', '<gv'}
  xnoremap {'>', '>gv|'}

  -- Use tab for indenting in visual mode
  vnoremap {'<Tab>', '>gv|'}
  vnoremap {'<S-Tab>', '<gv'}
  -- nnoremap('>', '>>_')
  -- nnoremap('<', '<<_')

  -- Code folding options
  nmap {'<leader>f0', ':set foldlevel=0<CR>'}
  nmap {'<leader>f1', ':set foldlevel=1<CR>'}
  nmap {'<leader>f2', ':set foldlevel=2<CR>'}
  nmap {'<leader>f3', ':set foldlevel=3<CR>'}
  nmap {'<leader>f4', ':set foldlevel=4<CR>'}
  nmap {'<leader>f5', ':set foldlevel=5<CR>'}
  nmap {'<leader>f6', ':set foldlevel=6<CR>'}
  nmap {'<leader>f7', ':set foldlevel=7<CR>'}
  nmap {'<leader>f8', ':set foldlevel=8<CR>'}
  nmap {'<leader>f9', ':set foldlevel=9999<CR>'}
end
