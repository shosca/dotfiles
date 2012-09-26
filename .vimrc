call pathogen#infect()
call pathogen#helptags()

scriptencoding utf-8

set number

" Don't be compatible with vi
set nocompatible

" Enable a nice big viminfo file
set viminfo='1000,f1,:1000,/1000
set history=500

" Make backspace delete lots of things
set backspace=indent,eol,start

" Show us the command we're typing
set showcmd

" Highlight matching parens
set showmatch

" Search options: incremental search, highlight search
set hlsearch
set incsearch

" Show full tags when doing search completion
set showfulltag

" Speed up macros
set lazyredraw

" No annoying error noises
set noerrorbells
set visualbell t_vb=
if has("autocmd")
    autocmd GUIEnter * set visualbell t_vb=
endif

" Use the cool tab complete menu
set wildmenu
set wildignore+=*.o,*~,.lo,*.hi
set suffixes+=.in,.a,.1

" Enable syntax highlighting
if has("syntax")
    syntax on
endif

" enable virtual edit in vblock mode, and one past the end
set virtualedit=block,onemore

" Set our fonts
if has("gui_running")
	if has("win32") || has("win64")
		set guifont=Ubuntu\ Mono:h10
	else
		set guifont=Monaco\ 10
	endif
endif

" Set colorscheme
syntax enable
set background=dark
colorscheme solarized

" No icky toolbar, menu or scrollbars in the GUI
if has('gui')
    set guioptions-=m
    set guioptions-=T
    set guioptions-=l
    set guioptions-=L
    set guioptions-=r
    set guioptions-=R
end

" By default, go for an indent of 4
set shiftwidth=4

" Don't make a # force column zero.
inoremap # X<BS>#

" Enable folds
if has("folding")
	set foldenable
	set foldmethod=indent
	set foldlevelstart=99
endif

set encoding=utf-8
set ruler
set autoread
set magic
set showmatch
set mat=2
set cul
set ffs=unix,dos,mac
set softtabstop=4
set cursorline
set laststatus=2
set mouse=a
set ts=4
set sw=4
set noeol
set binary
set nocompatible
set showfulltag
set scrolloff=3
set sidescrolloff=2

set wildignore+=.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif
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

filetype on
filetype plugin on
filetype indent on

if (&termencoding == "utf-8") || has("gui_running")
	set list
	set listchars=tab:»·,trail:·,extends:…,eol:¬
else
	set list
	set listchars=tab:>-,trail:.,extends:>,nbsp:_,eol:¬
endif
set fillchars=fold:-

" Nice window title
if has('title') && (has('gui_running') || &title)
    set titlestring=
    set titlestring+=%f\                                              " file name
    set titlestring+=%h%m%r%w                                         " flags
    set titlestring+=\ -\ %{v:progname}                               " program name
    set titlestring+=\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}  " working directory
endif

autocmd FileType text setlocal textwidth=78
autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass,cucumber set ai sw=2 sts=2 et
autocmd FileType python set sw=4 sts=4 et
autocmd BufRead *.mkd set ai formatoptions=tcroqn2 comments=n:&gt;
autocmd BufRead *.markdown set ai formatoptions=tcroqn2 comments=n:&gt;
autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd' | endif

autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
highlight Pmenu ctermbg=238 gui=bold

let g:ragtag_global_maps=1

let mapleader=","
" v_K is really really annoying
vmap K k

" In normal mode, jj escapes
inoremap jj <Esc>
" Don't use Ex mode, use Q for formatting
map Q gq

" highlight trailing whitespace
nmap <silent> <leader>s :set nolist!<CR>

map <silent> <F2> :NERDTreeToggle<CR>

nmap ; :

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

" run make nicely
noremap <leader>m :silent! :make \| :redraw! \| :botright :cw<cr>
map <silent><Leader>rt :!ctags --extra=+f --exclude=.git --exclude=log -R * `gem environment gemdir`/gems/*<CR><CR>
