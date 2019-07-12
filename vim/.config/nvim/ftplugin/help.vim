" Snippets from vim-help
" Credits: https://github.com/dahu/vim-help

if exists('b:did_ftplugin')
	finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

let b:undo_ftplugin = 'setlocal spell<'
setlocal nospell

setlocal nohidden
setlocal iskeyword+=:
setlocal iskeyword+=#
setlocal iskeyword+=-

wincmd L

" Jump to links with enter
nmap <buffer> <CR> <C-]>

" Jump back with backspace
nmap <buffer> <BS> <C-T>

" Skip to next option link
nmap <buffer> o /'[a-z]\{2,\}'<CR>

" Skip to previous option link
nmap <buffer> O ?'[a-z]\{2,\}'<CR>

" Skip to next subject link
nmap <buffer><nowait> s /\|\S\+\|<CR>l

" Skip to previous subject link
nmap <buffer> S h?\|\S\+\|<CR>l

" Skip to next tag (subject anchor)
nmap <buffer> t /\*\S\+\*<CR>l

" Skip to previous tag (subject anchor)
nmap <buffer> T h?\*\S\+\*<CR>l

let &cpoptions = s:save_cpo
