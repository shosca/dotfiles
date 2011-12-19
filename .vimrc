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

runtime! autoload/pathogen.vim
silent! call pathogen#runtime_append_all_bundles()

filetype plugin on

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType brail set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

set softtabstop=4

set cursorline
set laststatus=2
se nu
set mouse=a
set background=dark

"This should be in /etc/vim/vimrc or wherever you global vimrc is.
"But, if not, I for one can't live without it.
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set ts=4
set sw=4

" prevent vim from adding that stupid empty line at the end of every file
set noeol
set binary

" Don't be compatible with vi
set nocompatible

" Enable a big viminfo file
set viminfo='1000,f1,:1000,/1000
set history=500

"set backspace delete lots of things
set backspace=indent,eol,start

" Show full tags when doing search completion
set showfulltag

" Speed up macros
set lazyredraw

" No annoying error noises
set noerrorbells
set visualbell t_vb=
if has("autocmd")
    autocmd GUIEnter * set visualbell t_vb=
end

" Try to show at least three lines and two columns of context when
" scrolling
set scrolloff=3
set sidescrolloff=2

" Wrap on these
set whichwrap+=<,>,[,]

" Enable syntax highlighting
syntax enable

" enable virtual edit in vblock mode, and one past the end
set virtualedit=block,onemore

if has("gui_running")
	if has("win32") || has("win64")
		set guifont=Ubuntu_Mono:h10
	else
		set guifont=Ubuntu\ Mono\ 10
	endif
endif


colorscheme jellybeans
set background=dark

" No icky toolbar, menu or scrollbars in the GUI
"if has('gui')
"    set guioptions-=m
"    set guioptions-=T
"    set guioptions-=l
"    set guioptions-=L
"    set guioptions-=r
"    set guioptions-=R
"end

"Ignore these files when completing names and in Explorer
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

" Do clever indent things. Don't make a # force column zero.
set autoindent
set smartindent

set foldenable
set foldmethod=indent
set foldlevelstart=99

" Enable filetype settings
if has("eval")
	filetype on
	filetype plugin on
	filetype indent on
endif

try
	setlocal numberwidth=3
catch
endtry

" If possible and in gvim, use cursor row highlighting
if has("gui_running")
    set cursorline
end

" Include $HOME in cdpath
if has("file_in_path")
    let &cdpath=','.expand("$HOME").','.expand("$HOME").'/work'
endif

" Better include path handling
set path+=src/
let &inc.=' ["<]'

" Show tabs and trailing whitespace visually
if (&termencoding == "utf-8") || has("gui_running")
	set list
	set listchars=tab:»·,trail:·,extends:…,eol:¬
else
	set list
	set listchars=tab:>-,trail:.,extends:>,nbsp:_,eol:¬
endif

set fillchars=fold:-

"-----------------------------------------------------------------------
" completion
"-----------------------------------------------------------------------
"set dictionary=/usr/share/dict/words

"-----------------------------------------------------------------------
"" autocmds
"-----------------------------------------------------------------------

" content creation

if has("autocmd")
	augroup content
		autocmd!

		autocmd BufNewFile *.rb 0put ='# vim: set sw=4 sts=4 et tw=80 :' |
					\ 0put ='#!/usr/bin/env ruby' | set sw=4 sts=4 et tw=80 |
					\ norm G

		autocmd BufNewFile *.py 0put ='# vim: set sw=4 sts=4 et tw=80 :'|
					\ 0put ='#!/usr/bin/env python' | set sw=4 sts=4 et tw=80 |
					\ norm G

	augroup END
endif

"-----------------------------------------------------------------------
" mappings "-----------------------------------------------------------------------

" v_K is really really annoying
vmap K k

" Next buffer
nmap <C-w>. :bn<CR>

" tab completion
if has("eval")
	function! CleverTab()
		if strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
			return "\<Tab>"
		else
			return "\<C-N>"
		endif
	endfun
	inoremap <Tab> <C-R>=CleverTab()<CR>
	inoremap <S-Tab> <C-P>
endif
let g:SuperTabDefaultCompletionType = "context"
set completeopt=menuone,longest,preview


" Run pep8
let g:pep8_map='<leader>8'

let g:yankring_replace_n_pkey = '<leader>['
let g:yankring_replace_n_nkey = '<leader>]'

set shell=/bin/bash

au BufNewFile,BufRead *.less set filetype=less

if filereadable(expand("~/.vim_local"))
  source ~/.vim_local
endif
" Nice statusbar
set laststatus=2
set statusline=
set statusline+=%2*%-3.3n%0*\                " buffer number
set statusline+=%f\                          " file name
if has("eval")
	let g:scm_cache = {}
	fun! ScmInfo()
		let l:key = getcwd()
		if ! has_key(g:scm_cache, l:key)
			if (isdirectory(getcwd() . "/.git"))
				let g:scm_cache[l:key] = "[" . substitute(readfile(getcwd() . "/.git/HEAD", "", 1)[0],
							\ "^.*/", "", "") . "] "
			else
				let g:scm_cache[l:key] = ""
			endif
		endif
		return g:scm_cache[l:key]
	endfun
    set statusline+=%{ScmInfo()}             " scm info
endif
set statusline+=%h%1*%m%r%w%0*               " flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding},                " encoding
set statusline+=%{&fileformat}]              " file format
if filereadable(expand("$VIM/vimfiles/plugin/vimbuddy.vim"))
    set statusline+=\ %{VimBuddy()}          " vim buddy
endif
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
map <unique> <silent> <leader>tt :call MakeGreen()<cr>

" Run command-t file search
map <leader>f :FufFile **/<CR>
" Ack searching
nmap <leader>a <Esc>:Ack!

" Load the Gundo window
map <leader>g :GundoToggle<CR>

" Jump to the definition of whatever the cursor is on
map <leader>j :RopeGotoDefinition<CR>

" Rename whatever the cursor is on (including references to it)
map <leader>r :RopeRename<CR>

if has("win32") || has("win64")
    set shell=cmd.exe
    set shellcmdflag=/c
    set shellpipe=|
    set shellredir=>
endif
