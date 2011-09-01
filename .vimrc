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
		set guifont=Droid_Sans_Mono:h10
	else
		set guifont=Droid\ Sans\ Mono\ 9
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

source bindings.vim
source status.vim

if filereadable(expand("~/.vim_local"))
  source ~/.vim_local
endif