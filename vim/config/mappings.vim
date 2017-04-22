" Mappings {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

" In normal mode, jj escapes
inoremap jj <Esc>

" Disable Ex mode
:map Q <Nop>


" Wrapped lines goes down/up to next row, rather than next line in file.
noremap j gj
noremap k gk

" split management {
nnoremap sj <C-W>w<CR>
nnoremap sk <C-W>W<CR>
nnoremap su :resize +5<CR>
nnoremap si :resize -5<CR>
nnoremap sh :vertical resize +5<CR>
nnoremap sl :vertical resize -5<CR>
nnoremap sd :hide<CR>
nnoremap so :<CR>
nnoremap ss :split<Space>
nnoremap sv :vsplit<Space>
" }

" tab management {
nnoremap th :tabfirst<CR>
nnoremap tj :tabnext<CR>
nnoremap tk :tabprev<CR>
nnoremap tl :tablast<CR>
nnoremap tt :tabedit<Space>
nnoremap tn :tabnext<CR>
nnoremap tm :tabm<Space>
nnoremap td :tabclose<CR>
" }

function! WrapRelativeMotion(key, ...) " {
    " End/Start of line motion keys act relative to row/wrap width in the
    " presence of `:set wrap`, and relative to line for `:set nowrap`.
    " Default vim behaviour is to act relative to text line in both cases
    let vis_sel=""
    if a:0
        let vis_sel="gv"
    endif
    if &wrap
        execute "normal!" vis_sel . "g" . a:key
    else
        execute "normal!" vis_sel . a:key
    endif
endfunction

" Map g* keys in Normal, Operator-pending, and Visual+select
noremap $ :call WrapRelativeMotion("$")<CR>
noremap <End> :call WrapRelativeMotion("$")<CR>
noremap 0 :call WrapRelativeMotion("0")<CR>
noremap <Home> :call WrapRelativeMotion("0")<CR>
noremap ^ :call WrapRelativeMotion("^")<CR>
" Overwrite the operator pending $/<End> mappings from above
" to force inclusive motion with :execute normal!
onoremap $ v:call WrapRelativeMotion("$")<CR>
onoremap <End> v:call WrapRelativeMotion("$")<CR>
" Overwrite the Visual+select mode mappings from above
" to ensure the correct vis_sel flag is passed to function
vnoremap $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
vnoremap <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
vnoremap 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
vnoremap <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
vnoremap ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>
" }

" Stupid shift key fixes " {
if has("user_commands")
    command! -bang -nargs=* -complete=file E e<bang> <args>
    command! -bang -nargs=* -complete=file W w<bang> <args>
    command! -bang -nargs=* -complete=file Wq wq<bang> <args>
    command! -bang -nargs=* -complete=file WQ wq<bang> <args>
    command! -bang Wa wa<bang>
    command! -bang WA wa<bang>
    command! -bang Q q<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>
endif
" }

cmap Tabe tabe

" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

" Code folding options {
nmap <leader>f0 :set foldlevel=0<CR>
nmap <leader>f1 :set foldlevel=1<CR>
nmap <leader>f2 :set foldlevel=2<CR>
nmap <leader>f3 :set foldlevel=3<CR>
nmap <leader>f4 :set foldlevel=4<CR>
nmap <leader>f5 :set foldlevel=5<CR>
nmap <leader>f6 :set foldlevel=6<CR>
nmap <leader>f7 :set foldlevel=7<CR>
nmap <leader>f8 :set foldlevel=8<CR>
nmap <leader>f9 :set foldlevel=9<CR>
" }

" Most prefer to toggle search highlighting rather than clear the current
" search results. To clear search highlighting rather than toggle it on
nmap <silent> <leader>/ :set invhlsearch<CR>
" nmap <silent> <leader>/ :nohlsearch<CR>

" Shortcuts
" Change Working Directory to that of the current file
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null

" Some helpers to edit mode http://vimcasts.org/e/14 " {
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%
" }

" Adjust viewports to the same size
map <Leader>= <C-w>=

" Map <Leader>ff to display all lines with keyword under cursor
" and ask which one to jump to
nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

" Easier horizontal scrolling
map zl zL
map zh zH

" Easier formatting
nnoremap <silent> <leader>q gwip

" edit the vimrc file
nmap <silent> <Leader>ev :e $MYVIMRC<CR>
nmap <silent> <Leader>sv :so $MYVIMRC<CR>

"inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

if executable('zeal')
  autocmd MyAutoCmd FileType ansible,go,php,css,less,html,markdown
        \ nmap <silent><buffer> K :!zeal --query "<C-R>=split(&ft, '\.')[0]<CR>:<cword>"&<CR><CR>
  autocmd MyAutoCmd FileType javascript,javascript.jsx,sql,ruby,conf,sh
        \ nmap <silent><buffer> K :!zeal --query "<cword>"&<CR><CR>
endif

augroup gitrebase
  autocmd FileType gitrebase nnoremap <buffer> <silent> P :Pick<cr>
  autocmd FileType gitrebase nnoremap <buffer> <silent> R :Reword<cr>
  autocmd FileType gitrebase nnoremap <buffer> <silent> E :Edit<cr>
  autocmd FileType gitrebase nnoremap <buffer> <silent> S :Squash<cr>
  autocmd FileType gitrebase nnoremap <buffer> <silent> F :Fixup<cr>
  autocmd FileType gitrebase nnoremap <buffer> <silent> C :Cycle<cr>
augroup END
