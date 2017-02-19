" Modeline and Notes {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

setlocal formatoptions=qroct " Correct indentation after opening a phpdocblock
setlocal makeprg=php\ -l\ %  " Use php syntax check when doing :make
setlocal errorformat=%m\ in\ %f\ on\ line\ %l
setlocal matchpairs-=<:>     " Annoying when not closing <?php tag
"setlocal iskeyword+=\\       " Add the namespace separator as a keyword
"setlocal path+=/usr/local/share/pear
