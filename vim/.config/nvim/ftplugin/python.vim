setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal textwidth=120
setlocal expandtab
setlocal smarttab

au FileType python nnoremap <leader>p oimport pdb;pdb.set_trace()  # flake8: noqa<Esc>
au FileType python nnoremap <leader>pu oimport pudb;pudb.set_trace()  # flake8: noqa<Esc>
au FileType python nnoremap <leader>rp ofrom remote_pdb import RemotePdb; RemotePdb("0.0.0.0", 8000).set_trace()  # flake8: noqa<ESC>
au FileType python nnoremap <leader>z :!zimports %<CR>
