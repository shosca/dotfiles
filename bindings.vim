
" In normal mode, jj escapes
inoremap jj <Esc>

" Make
:command -nargs=* Make make <args> | cwindow 3

let mapleader = ","

" Don't use Ex mode, use Q for formatting
map Q gq

" highlight trailing whitespace
" set listchars=tab:▷⋅,trail:·,eol:$
nmap <silent> <leader>s :set nolist!<CR>

" extended '%' mapping for if/then/else/end etc
runtime macros/matchit.vim

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" Ctrl-N to disable search match highlight
nmap <silent> <C-N> :silent noh<CR>

" Ctrol-E to switch between 2 last buffers
nmap <C-E> :b#<CR>

" ,b to display current buffers list
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
" let g:miniBufExplVSplit = 25
" let g:miniBufExplorerMoreThanOne = 100
" let g:miniBufExplUseSingleClick = 1
nmap <Leader>b :MiniBufExplorer<cr>

" ,sh to open vimshell window
nmap <Leader>sh :ConqueSplit bash<cr>

" ,r to open vimshell window
nmap <Leader>r :ConqueSplit

" map ,y to show the yankring
nmap <leader>y :YRShow<cr>

" map ,E to show errors
nmap <leader>E :Errors<cr>

" edit the vimrc file
nmap <silent> ,ev :e $MYVIMRC<CR>
nmap <silent> ,sv :so $MYVIMRC<CR>

if has("mouse")
  set mouse=a
endif

" tab navigation like firefox
" nmap <C-S-tab> :tabprevious<cr>
"nmap <C-tab> :tabnext<cr>
"map <C-S-tab> :tabprevious<cr>
"map <C-tab> :tabnext<cr>
"imap <C-S-tab> :tabprevious<cr>
"imap <C-tab> :tabnext<cr>
"nmap <C-t> :tabnew<cr>
"imap <C-t> :tabnew<cr>

" disable annoying f1
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" save some time
nnoremap ; :

au FocusLost * :wa

" strip all whitespace in the current file
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" fold tag
nnoremap <leader>ft Vatzf

" sort css properties
nnoremap <leader>S ?{<CR>jV/^\s*\}?$<CR>k:sort<CR>:noh<CR>

" make a new vertical split and switch to it
nnoremap <leader>w <C-w>v<C-w>l

" make
nmap <leader>m :make<CR>

" navigate splits easier
nnoremap <C-h> <C-W>h
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-l> <C-W>l

" and lets make these all work in insert mode too
imap <C-W> <C-O><C-W>

map <leader>td <Plug>TaskList

" open/close the quickfix window
nmap <leader>c :copen
nmap <leader>cc :cclose

" Open NerdTree
map <leader>n :NERDTreeToggle<CR>

" Run command-t file search
map <leader>f :CommandT<CR>
" Ack searching 
nmap <leader>a <Esc>:Ack!

" Load the Gundo window
map <leader>g :GundoToggle<CR>

" Jump to the definition of whatever the cursor is on
map <leader>j :RopeGotoDefinition<CR>

" Rename whatever the cursor is on (including references to it)
map <leader>r :RopeRename<CR>
