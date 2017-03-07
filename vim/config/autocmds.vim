" Modeline and Notes {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

augroup MyAutoCmd
    au!

    " ensure every file does syntax highlighting (full)
    autocmd BufEnter * :syntax sync fromstart
    autocmd BufEnter,WinEnter,InsertLeave * set cursorline
    autocmd BufLeave,WinLeave,InsertEnter * set nocursorline
    autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif

    " NOTE: ctags find the tags file from the current path instead of the path of currect file
    autocmd BufNewFile,BufEnter * set cpoptions+=d

    " Remove trailing whitespaces and ^M chars
    autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,xsl,xslt,html,yml,perl,sql autocmd BufWritePre <buffer> call StripTrailingWhitespace()
    autocmd FileType go autocmd BufWritePre <buffer> Fmt

    " Instead of reverting the cursor to the last position in the buffer, we
    " set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    autocmd FileType ruby,haml,eruby,yaml,html,sass,cucumber,sh set ai sw=2 sts=2 et

    autocmd BufWritePre,BufRead,BufNewFile *.css,*.scss,*.less setlocal foldmethod=marker foldmarker={,}

    " this will avoid bug in my project with namespace ex, the vim will tree ex:: as modeline.
    autocmd FileType c,cpp,cs,swig set nomodeline
    autocmd FileType c,cpp,java,javascript set comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,f://
    autocmd FileType cs set comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,f:///,f://
    autocmd FileType vim set comments=sO:\"\ -,mO:\"\ \ ,eO:\"\",f:\"
    autocmd FileType lua set comments=f:--
    autocmd FileType vim setlocal foldmethod=marker
augroup END
