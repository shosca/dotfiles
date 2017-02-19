" Unite {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

let g:unite_source_history_yank_enable = 1
let g:unite_source_history_yank_linut = 10000
let g:unite_source_history_yank_file = $VARPATH.'/yank_history.txt'
let g:unite_marked_icon = '✓'
if executable('ag')
    let g:unite_source_rec_aync_command = [ 'ag', '-l', '-g', '', '--nocolor'  ]
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts =
        \ '-i --line-numbers --nocolor --nogroup --hidden --ignore ' .
        \  '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
    let g:unite_source_grep_recursive_opt = ''
endif
