" Modeline and Notes {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

set nowrap                    " Do not wrap long lines
set autoindent                " Indent at the same level of the previous line
set shiftwidth=4              " Use indents of 4 spaces
set expandtab                 " Tabs are spaces, not tabs
set tabstop=4                 " An indentation every four columns
set softtabstop=4             " Let backspace delete indent
set nojoinspaces              " Prevents inserting two spaces after punctuation on a join (J)
set splitright                " Puts new vsplit windows to the right of the current
set splitbelow                " Puts new split windows to the bottom of the current
"set matchpairs+=<:>          " Match, to be used with %
set pastetoggle=<F12>         " pastetoggle (sane indentation on pastes)
set colorcolumn=120
syntax on                     " Syntax highlighting
set mouse=a                   " Automatically enable mouse usage
"set ttymouse=sgr             " Stick to SGR 1006 mouse mode
set mousehide                 " Hide the mouse cursor while typing
scriptencoding utf-8
if has('clipboard')
    if has('unnamedplus')
        " When possible use + register for copy-paste
        set clipboard=unnamed,unnamedplus
    else
        " On mac and Windows, use * register for copy-paste
        set clipboard=unnamed
    endif
endif
set shortmess+=filmnrxoOtT    " Abbrev. of messages (avoids 'hit enter')
set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
set virtualedit=onemore       " Allow for cursor beyond last character
set history=1000              " Store a ton of history (default is 20)
set spell                     " Spell checking on
set hidden                    " Allow buffer switching without saving
set iskeyword-=.              " '.' is an end of word designator
set iskeyword-=#              " '#' is an end of word designator
set iskeyword-=-              " '-' is an end of word designator

" No annoying error noises
set noerrorbells
set visualbell t_vb=
if has("autocmd")
    autocmd GUIEnter * set visualbell t_vb=
endif

" http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
" Restore cursor to file position in previous editing session
function! ResCur()
    if line("'\"") <= line("$")
        silent! normal! g`"
        return 1
    endif
endfunction

augroup resCur
    autocmd!
    autocmd BufWinEnter * call ResCur()
augroup END

set backup                  " Backups are nice ...
set backupcopy=yes
if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

if executable('ag')
    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
endif
let g:pymode_indent=0

let tags = expand('$VARPATH/vim/tags')
