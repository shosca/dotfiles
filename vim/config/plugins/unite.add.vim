" Unite {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

function! s:unite_settings()
   nmap <buffer> <ESC> <Plug>(unite_exit)
   imap <buffer> <C-j>   <Plug>(unite_select_next_line)
   imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
   nmap <buffer> <C-j> j
   nmap <buffer> <C-k> k
   imap <buffer><expr> <C-s> unite#do_action("split")
   imap <buffer><expr> <C-v> unite#do_action("vsplit")
   imap <buffer><expr> <C-t> unite#do_action("tabopen")
endfunction
autocmd FileType unite call s:unite_settings()

nnoremap [unite] <Nop>
exe 'nmap '.g:unite_leader.' [unite]'
if has('nvim')
    nnoremap <silent> [unite]p :<C-u>Unite -start-insert file_rec/neovim<CR>
else
    nnoremap <silent> [unite]p :<C-u>Unite -start-insert file_rec/async<CR>
endif
nnoremap <silent> [unite]o :<C-u>Unite buffer<CR>
nnoremap <silent> [unite]o :<C-u>Unite -buffer-name=outline -start-insert -auto-preview -split outline<CR>
nnoremap <silent> [unite]k :<C-u>Unite change jump<CR>
nnoremap <silent> [unite]f :<C-u>Unite grep -no-empty -no-quit -resume<CR>
nnoremap <silent> [unite]y :<C-u>Unite -default-action=append register history/yank<CR>
nnoremap <silent> [unite]l :<C-u>Unite -start-insert command history/command<CR>

call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_reverse'])
call unite#custom#source('file_mru,file_rec,file_rec/async,grep,locate',
  \ 'ignore_pattern', join(['\.git/', 'tmp/', 'bundle/'], '\|'))
