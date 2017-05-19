setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal textwidth=120
setlocal expandtab
setlocal smarttab
setlocal formatprg=yapf

au FileType python nnoremap <leader>p oimport pdb;pdb.set_trace()  # flake8: noqa<Esc>
au FileType python nnoremap <leader>pu oimport pudb;pudb.set_trace()  # flake8: noqa<Esc>
