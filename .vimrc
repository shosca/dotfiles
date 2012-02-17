call pathogen#infect()
set encoding=utf-8
set nocompatible
set wildmenu
set ruler
set autoread
set hlsearch
set incsearch
set magic
set showmatch
set mat=2
set cul
set ffs=unix,dos,mac
set softtabstop=4
set cursorline
set laststatus=2
se nu
set mouse=a
set background=dark
set ts=4
set sw=4
set noeol
set binary
set nocompatible
set viminfo='1000,f1,:1000,/1000
set history=500
set backspace=indent,eol,start
set showfulltag
set lazyredraw
set noerrorbells
set visualbell t_vb=
set scrolloff=3
set sidescrolloff=2
if has("gui_running")
	if has("win32") || has("win64")
		set guifont=Ubuntu_Mono:h10
	else
		set guifont=Ubuntu\ Mono\ 10
	endif
endif
set wildignore=.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*.so
set wildignore+=.git\*,.hg\*,.svn\*,*.dll,*.exe
if has("win32") || has("win64")
	set directory=$TMP
	set backupdir=$TMP
else
	set backupdir=~/.backup,.
	set directory=~/.backup,~/tmp,.
end
set autoindent
set smartindent

set foldenable
set foldmethod=indent
set foldlevelstart=99

filetype on
filetype plugin on
filetype indent on
au BufWritePost *.coffee silent CoffeeMake! -b | cwindow | redraw!

if (&termencoding == "utf-8") || has("gui_running")
	set list
	set listchars=tab:»·,trail:·,extends:…,eol:¬
else
	set list
	set listchars=tab:>-,trail:.,extends:>,nbsp:_,eol:¬
endif
set fillchars=fold:-

syntax enable
set background=dark
colorscheme solarized

vmap K k

" Nice statusbar
set laststatus=2
set statusline=
set statusline+=%2*%-3.3n%0*\                " buffer number
set statusline+=%f\                          " file name
set statusline+=%h%1*%m%r%w%0*               " flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding},                " encoding
set statusline+=%{&fileformat}]              " file format
set statusline+=%=                           " right align
set statusline+=%2*0x%-8B\                   " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset

" Nice window title
if has('title') && (has('gui_running') || &title)
    set titlestring=
    set titlestring+=%f\                                              " file name
    set titlestring+=%h%m%r%w                                         " flags
    set titlestring+=\ -\ %{v:progname}                               " program name
    set titlestring+=\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}  " working directory
endif

" In normal mode, jj escapes
inoremap jj <Esc>
" Don't use Ex mode, use Q for formatting
map Q gq
" highlight trailing whitespace
" set listchars=tab:▷⋅,trail:·,eol:$
nmap <silent> <leader>s :set nolist!<CR>
" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>
" Ctrl-N to disable search match highlight
nmap <silent> <C-N> :silent noh<CR>
" edit the vimrc file
nmap <silent> ,ev :e $MYVIMRC<CR>
nmap <silent> ,sv :so $MYVIMRC<CR>
" disable annoying f1
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>
" navigate splits easier
nnoremap <C-h> <C-W>h
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-l> <C-W>l