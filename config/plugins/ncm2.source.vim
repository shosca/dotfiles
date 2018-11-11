" uppress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

set completeopt=menuone         " Show menu even for one item
set completeopt+=noselect       " Do not select a match in the menu
if has('patch-7.4.775')
  set completeopt+=noinsert
endif

" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
inoremap <c-c> <ESC>

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

autocmd BufEnter  *  call ncm2#enable_for_buffer()

" wrap existing omnifunc
" Note that omnifunc does not run in background and may probably block the
" editor. If you don't want to be blocked by omnifunc too often, you could
" add 180ms delay before the omni wrapper:
"  'on_complete': ['ncm2#on_complete#delay', 180,
"               \ 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
"
"au User Ncm2Plugin call ncm2#register_source({
        "\ 'name' : 'css',
        "\ 'priority': 9, 
        "\ 'subscope_enable': 1,
        "\ 'scope': ['css','scss'],
        "\ 'mark': 'css',
        "\ 'word_pattern': '[\w\-]+',
        "\ 'complete_pattern': ':\s*',
        "\ 'on_complete': ['ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
        "\ })
