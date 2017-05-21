" Theme
" -----

" Enable 256 color term
set t_Co=256

hi MatchParen cterm=bold term=bold

set termguicolors
let base16colorspace=256
set background=dark
colorscheme gruvbox

autocmd MyAutoCmd ColorScheme * colorscheme gruvbox

set tabpagemax=15               " Only show 15 tabs
set showmode                    " Display the current mode

" this is a performance killer
" set cursorline                  " Highlight current line


if has('cmdline_info')
  set ruler                   " Show the ruler
  set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
  set showcmd                 " Show partial commands in status line and
                              " Selected characters/lines in visual mode
endif

set linespace=0                 " No extra spaces between rows
set number                      " Line numbers on
"set showmatch                   " Show matching brackets/parenthesis
set incsearch                   " Find as you type search
set hlsearch                    " Highlight search terms
set winminheight=0              " Windows can be 0 line high
set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
set wildignore=*.pyc,*.o,*.lo,*.la,*.exe,*.swp,*.db,*.bak,*.old,*.dat,*.,tmp,*.mdb,*~,~*
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set scrolljump=5                " Lines to scroll when cursor leaves screen
set scrolloff=3                 " Minimum lines to keep above and below cursor
set foldenable                  " Auto fold code
set list
set listchars=tab:›\ ,eol:¬,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

" Statusline {{{
let s:stl  = " %7*%{&paste ? '=' : ''}%*"         " Paste symbol
let s:stl .= "%4*%{&readonly ? '' : '#'}%*"       " Modifide symbol
let s:stl .= "%6*%{badge#mode('⚠', 'Z')}"         " Readonly symbol
let s:stl .= '%*%n'                               " Buffer number
let s:stl .= "%6*%{badge#modified('+')}%0*"       " Write symbol
let s:stl .= ' %1*%{badge#filename()}%*'          " Filename
let s:stl .= ' %<'                                " Truncate here
let s:stl .= '%( %{badge#branch()} %)'           " Git branch name
let s:stl .= "%4*%(%{badge#trails('WS:%s')} %)"  " Whitespace
let s:stl .= '%(%{badge#syntax()} %)%*'           " syntax check
let s:stl .= '%='                                 " Align to right
let s:stl .= '%{badge#format()} %4*%*'           " File format
let s:stl .= '%( %{&fenc} %)'                     " File encoding
let s:stl .= '%4*%*%( %{&ft} %)'                 " File type
let s:stl .= '%3*%2* %l/%2c%4p%% '               " Line and column
let s:stl .= '%{badge#indexing()}%*'              " Indexing tags indicator

" Non-active Statusline {{{
let s:stl_nc = " %{badge#mode('⚠', 'Z')}%n"    " Readonly & buffer
let s:stl_nc .= "%6*%{badge#modified('+')}%*"  " Write symbol
let s:stl_nc .= ' %{badge#filename()}'         " Relative supername
let s:stl_nc .= '%='                           " Align to right
let s:stl_nc .= '%{&ft} '                      " File type
" }}}

" Highlights: Statusline {{{
highlight StatusLine   ctermfg=236 ctermbg=248 guifg=#30302c guibg=#a8a897
highlight StatusLineNC ctermfg=236 ctermbg=242 guifg=#30302c guibg=#666656

" Filepath color
highlight User1 guifg=#D7D7BC guibg=#30302c ctermfg=251 ctermbg=236
" Line and column information
highlight User2 guifg=#a8a897 guibg=#4e4e43 ctermfg=248 ctermbg=239
" Line and column corner arrow
highlight User3 guifg=#4e4e43 guibg=#30302c ctermfg=239 ctermbg=236
" Buffer # symbol and whitespace or syntax errors
highlight User4 guifg=#666656 guibg=#30302c ctermfg=242 ctermbg=236
" Write symbol
highlight User6 guifg=#cf6a4c guibg=#30302c ctermfg=167 ctermbg=236
" Paste symbol
highlight User7 guifg=#99ad6a guibg=#30302c ctermfg=107 ctermbg=236
" Syntax and whitespace
highlight User8 guifg=#ffb964 guibg=#30302c ctermfg=215 ctermbg=236
" }}}

let s:disable_statusline =
	\ 'denite\|unite\|vimfiler\|tagbar\|nerdtree\|undotree\|gundo\|diff'

" Toggle Statusline {{{
augroup statusline
  autocmd!
  autocmd FileType,WinEnter,BufWinEnter,BufReadPost *
        \ if &filetype !~? s:disable_statusline
        \ | let &l:statusline = s:stl
        \ | endif
  autocmd WinLeave *
        \ if &filetype !~? s:disable_statusline
        \ | let &l:statusline = s:stl_nc
        \ | endif
augroup END "}}}

" }}}

" Tabline {{{
" ---------------------------------------------------------
" TabLineFill: Tab pages line, where there are no labels
hi TabLineFill ctermfg=234 ctermbg=236 guifg=#1C1C1C guibg=#303030 cterm=NONE gui=NONE
" TabLine: Not-active tab page label
hi TabLine     ctermfg=243 ctermbg=236 guifg=#767676 guibg=#303030 cterm=NONE gui=NONE
" TabLineSel: Active tab page label
hi TabLineSel  ctermfg=241 ctermbg=234 guifg=#626262 guibg=#1C1C1C cterm=NONE gui=NONE
" Custom
highlight TabLineSelShade  ctermfg=235 ctermbg=234 guifg=#262626 guibg=#1C1C1C
highlight TabLineAlt       ctermfg=252 ctermbg=238 guifg=#D0D0D0 guibg=#444444
highlight TabLineAltShade  ctermfg=238 ctermbg=236 guifg=#444444 guibg=#303030

function! Tabline() abort "{{{
  " Active project tab
  let s:tabline =
    \ '%#TabLineAlt# %{badge#project()} '.
    \ '%#TabLineAltShade#▛'.
    \ '%#TabLineFill#  '

  let nr = tabpagenr()
  for i in range(tabpagenr('$'))
    if i + 1 == nr
      " Active tab
      let s:tabline .=
            \ '%#TabLineSelShade#░%#TabLineSel#'.
            \ '%'.(i+1).'T%{badge#label('.(i+1).', "▛", "N/A")} '.
            \ '%#TabLineFill#▞ '
    else
      " Normal tab
      let s:tabline .=
            \ '%#TabLine# '.
            \ '%'.(i+1).'T%{badge#label('.(i+1).', "▛", "N/A")} '.
            \ '▘ '
    endif
  endfor
  " Empty space and session indicator
  let s:tabline .=
            \ '%#TabLineFill#%T%=%#TabLine#%{badge#session("['.fnamemodify(v:this_session, ':t:r').']")}'
  return s:tabline
endfunction "}}}

let &tabline='%!Tabline()'
" }}}

