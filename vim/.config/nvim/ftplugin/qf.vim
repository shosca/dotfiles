" Snippets from vim-qf
" Credits: https://github.com/romainl/vim-qf

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

let b:undo_ftplugin = 'setl fo< com< ofu<'

setlocal winminheight=1 winheight=3
setlocal nowrap
setlocal norelativenumber number
setlocal linebreak
setlocal nolist
setlocal cursorline
setlocal nobuflisted

nnoremap <buffer> <CR> <CR><C-w>p
nnoremap <buffer> sv <C-w><CR>
nnoremap <buffer> sg <C-w><Enter><C-w>L
nnoremap <buffer> st <C-w><CR><C-w>T
nnoremap <silent><buffer> p :call <SID>preview_file()<CR>
nnoremap <silent><buffer> q :pclose!<CR>:quit<CR>
nnoremap <buffer> o <CR><C-w>p

let b:qf_isLoc = ! empty(getloclist(0))
if b:qf_isLoc == 1
  nnoremap <buffer> O <CR>:lclose<CR>
else
  nnoremap <buffer> O <CR>:cclose<CR>
endif

let &cpoptions = s:save_cpo
