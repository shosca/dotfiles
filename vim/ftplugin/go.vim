augroup gofmt
    au!
    autocmd FileType go autocmd BufWritePre <buffer> Fmt
augroup END
