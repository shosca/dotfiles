setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal textwidth=120
setlocal expandtab
setlocal smarttab

au FileType python nnoremap <leader>p obreakpoint()<Esc>
au FileType python nnoremap <leader>z :!zimports %<CR>
