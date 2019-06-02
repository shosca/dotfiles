let g:coc_global_extensions = [
      \ 'coc-calc',
      \ 'coc-dictionary',
      \ 'coc-emoji',
      \ 'coc-eslint',
      \ 'coc-git',
      \ 'coc-highlight',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-lists',
      \ 'coc-marketplace',
      \ 'coc-pairs',
      \ 'coc-prettier',
      \ 'coc-python',
      \ 'coc-snippets',
      \ 'coc-syntax',
      \ 'coc-tag',
      \ 'coc-tslint-plugin',
      \ 'coc-tsserver',
      \ 'coc-yank',
      \ ]

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

function! s:GoToDefinition()
  function! s:handler(err, resp)
    let line = coc#util#echo_line()
    if line =~ 'Definition provider not found for current document'
      call searchdecl(expand('<cword>'))
    endif
  endfunction

  call CocActionAsync('jumpDefinition', function('s:handler'))
endfunction

nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)
nmap <silent> <leader>d <Plug>(coc-definition)
nmap <silent> <leader>K :call <SID>show_documentation()<CR>
nmap <silent> <leader>n <Plug>(coc-references)
nmap <silent> <leader>r <Plug>(coc-rename)

nmap <silent> gd :call <SID>GoToDefinition()<CR>
nmap <silent> gD <Plug>(coc-declaration)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gn <Plug>(coc-rename)
nmap <silent> ge <Plug>(coc-diagnostic-next)
nmap <silent> gx <Plug>(coc-fix-current)
nmap <silent> ga <Plug>(coc-codeaction)
nmap <silent> gj <Plug>(coc-git-nextchunk)
nmap <silent> gk <Plug>(coc-git-prevchunk)
nmap <silent> gs <Plug>(coc-git-chunkinfo)
nmap <silent> gm <Plug>(coc-git-commit)

autocmd CursorHold * silent call CocActionAsync('highlight')

inoremap <silent><expr> <c-space> coc#refresh()