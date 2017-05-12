" Modeline and Notes {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

augroup StripTrailingWhitespace
    au!

    " Remove trailing whitespaces and ^M chars
    autocmd FileType c,cpp,java,go,php,ruby,javascript,puppet,python,rust,twig,xml,xsl,xslt,html,yaml,perl,sql autocmd BufWritePre <buffer> call StripTrailingWhitespace()
augroup END
