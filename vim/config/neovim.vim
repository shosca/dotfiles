" Write history on idle
augroup MyAutoCmd
  autocmd CursorHold * if exists(':rshada') | rshada | wshada | endif
augroup END

" Search and use environments specifically made for Neovim.
let g:python_host_prog = '/usr/bin/python2.7'
let g:python3_host_prog = '/usr/bin/python3.6'
