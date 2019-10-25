setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal textwidth=120
setlocal expandtab
setlocal smarttab
setlocal formatprg=prettier

au FileType python nnoremap <leader>p odebugger;<Esc>
