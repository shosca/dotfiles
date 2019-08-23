
if &compatible
  set nocompatible
endif

" Constants
let s:is_sudo = $SUDO_USER !=# '' && $USER !=# $SUDO_USER

" Global Mappings {
" Use spacebar as leader and ; as secondary-leader
" Required before loading plugins!
let g:mapleader="\<Space>"
let g:maplocalleader=","
" }

" Paths and directories {
" Set main configuration directory, and where cache is stored.
let $VIMPATH = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')
let $VARPATH = expand(($XDG_CACHE_HOME ? $XDG_CACHE_HOME : '~/.cache').'/vim')

" Create missing dirs i.e. cache/{undo,backup}
call mkdir(expand('$VARPATH/undo'), 'p')
call mkdir(expand('$VARPATH/backup'), 'p')
call mkdir(expand('$VARPATH/swap'), 'p')
call mkdir(expand('$VARPATH/view'), 'p')

" Ensure custom spelling directory
call mkdir(expand('$VIMPATH/nvim/spell'), 'p')

set undofile swapfile nobackup
set directory=$VARPATH/swap/,$VARPATH,~/tmp,/var/tmp,/tmp
set undodir=$VARPATH/undo/,$VARPATH,~/tmp,/var/tmp,/tmp
set backupdir=$VARPATH/backup/,$VARPATH,~/tmp,/var/tmp,/tmp
set viewdir=$VARPATH/view/
set nospell spellfile=$VIMPATH/nvim/spell/en.utf-8.add

" History saving
set history=2000
if has('nvim')
  "  ShaDa/viminfo:
  "   ' - Maximum number of previously edited files marks
  "   < - Maximum number of lines saved for each register
  "   @ - Maximum number of items in the input-line history to be
  "   s - Maximum size of an item contents in KiB
  "   h - Disable the effect of 'hlsearch' when loading the shada
  set shada='300,<10,@50,s100,h
else
  set viminfo='300,<10,@50,h,n$VARPATH/viminfo
endif
" }

" Python setup {
if isdirectory($VARPATH.'/venv/neovim2')
  let g:python_host_prog = $VARPATH.'/venv/neovim2/bin/python'
endif
if isdirectory($VARPATH.'/venv/neovim3')
  let g:python3_host_prog = $VARPATH.'/venv/neovim3/bin/python'
endif

if has('pythonx')
  if has('python3')
    set pyxversion=3
  elseif has('python')
    set pyxversion=2
  endif
endif
" }

" Initialization {
if has('vim_starting')

  " Write history on idle
  augroup MyAutoCmd
    autocmd CursorHold * if exists(':rshada') | rshada | wshada | endif
  augroup END

  " Load vault settings {
  if filereadable(expand('$VIMPATH/nvim/.vault.vim'))
    execute 'source' expand('$VIMPATH/nvim/.vault.vim')
  endif
  " }

  " Load less plugins while SSHing to remote machines {
  if len($SSH_CLIENT)
    let $VIM_MINIMAL = 1
  endif
  " }

  " Disable default plugins "{

  " Disable menu.vim
  if has('gui_running')
    set guioptions=Mc
  endif

  " Disable pre-bundled plugins
  let g:loaded_2html_plugin = 1
  let g:loaded_getscript = 1
  let g:loaded_getscriptPlugin = 1
  let g:loaded_gzip = 1
  let g:loaded_logiPat = 1
  let g:loaded_matchit = 1
  let g:loaded_matchparen = 1
  let g:loaded_rrhelper = 1
  let g:loaded_ruby_provider = 1
  let g:loaded_shada_plugin = 1
  let g:loaded_tar = 1
  let g:loaded_tarPlugin = 1
  let g:loaded_tutor_mode_plugin = 1
  let g:loaded_vimball = 1
  let g:loaded_vimballPlugin = 1
  let g:loaded_zip = 1
  let g:loaded_zipPlugin = 1
  let g:netrw_nogx = 1
  " }

  if has('nvim')
    set inccommand=nosplit

    " Make escape work in the Neovim terminal.
    tnoremap <Esc> <C-\><C-n>

    " Make navigation into and out of Neovim terminal splits nicer.
    tnoremap <C-h> <C-\><C-N><C-w>h
    tnoremap <C-j> <C-\><C-N><C-w>j
    tnoremap <C-k> <C-\><C-N><C-w>k
    tnoremap <C-l> <C-\><C-N><C-w>l
  endif
endif
" }

" Initialize dein.vim  {

" - Ensure dein {
if &runtimepath !~# '/dein.vim'
  let s:dein_dir = expand('$VARPATH/dein').'/repos/github.com/Shougo/dein.vim'
  if ! isdirectory(s:dein_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
  endif

  execute 'set runtimepath+='.substitute(fnamemodify(s:dein_dir, ':p') , '/$', '', '')
endif
" }

function! s:yaml_check_ruby() abort " {
  call system("ruby -e 'require \"json\"; require \"yaml\"'")
  return (v:shell_error == 0) ? 1 : 0
endfunction
" }

function! s:yaml_check_yaml2json() " {
  try
    let result = system('yaml2json', "---\ntest: 1")
    if v:shell_error != 0
      return 0
    endif
    let result = json_decode(result)
    return result.test
  catch
  endtry
  return 0
endfunction
" }

function! LoadYaml(filename) abort " {
  if exists('*json_decode')
    if s:yaml_check_yaml2json()
      return json_decode(system('yaml2json', readfile(a:filename)))
    elseif s:yaml_check_ruby()
      return json_decode(
            \ system("ruby -e 'require \"json\"; require \"yaml\"; ".
            \ "print JSON.generate YAML.load \$stdin.read'",
            \ readfile(a:filename)))
    else
      let js = system("python3 -c \"import yaml, json; print(json.dumps(yaml.load(open('".a:filename."', 'r'), Loader=yaml.FullLoader)))\"")
      return json_decode(js)
    endif
  else
python3 << endpython
import vim, yaml
with open(vim.eval('a:filename'), 'rb') as f:
    vim.vars['yaml_file'] = yaml.load(f, Loader=yaml.FullLoader)
endpython
    return g:yaml_file
  endif
endfunction " }

function! s:dein_load_yaml(plug) abort " {
  for plugin in a:plug
    let s:plug_name = split(plugin['repo'], "/")[-1]

    for s:event in ['add', 'source', 'always']
      let s:plug_name_event = expand('$PLUGINPATH/').s:plug_name.'.'.s:event.'.vim'
      if filereadable(s:plug_name_event)
        let plugin['hook_'.s:event] = 'source '.s:plug_name_event
      endif
    endfor
    call dein#add(plugin['repo'], extend(plugin, {}, 'keep'))
  endfor
endfunction " }

function! s:source_file(path, ...) abort "{
  let use_global = get(a:000, 0, ! has('vim_starting'))
  let abspath = resolve(expand($VIMPATH.'/nvim/'.a:path))
  if ! use_global
    execute 'source' fnameescape(abspath)
    return
  endif

  let content = map(readfile(abspath),
        \ "substitute(v:val, '^\\W*\\zsset\\ze\\W', 'setglobal', '')")
  let tempfile = tempname()
  try
    call writefile(content, tempfile)
    execute printf('source %s', fnameescape(tempfile))
  finally
    if filereadable(tempfile)
      call delete(tempfile)
    endif
  endtry
endfunction " }

" - Dein config {
let g:dein#install_max_processes = 16
let g:dein#install_progress_type = 'echo'
let g:dein#enable_notification = 0
let g:dein#install_log_filename = $VARPATH.'/dein.log'
let hook_immediate = []
let plugs = []

let s:dein_path = expand('$VARPATH/dein')
let $PLUGINPATH = expand('$VIMPATH/nvim/plugins.d')
let s:plugins = expand('$VARPATH/plugins.yaml')

silent exec '!cat $(find '.expand('$PLUGINPATH').' -type f -iname "*.yaml") > '.s:plugins
" }

" - Load plugin configs {
try
  let g:plugs = LoadYaml(s:plugins)
catch /.*/
  echomsg v:exception
  echomsg 'Error loading '.s:plugins.' ...'
  echomsg 'Caught: ' v:exception
endtry

for plugin in g:plugs
  if has_key(plugin, 'hook_always')
    execute plugin['hook_always']
  endif
endfor
" }

" - Initialize dein {
if dein#load_state(s:dein_path)

  call dein#begin(s:dein_path, [s:plugins])
  call dein#add('Shougo/dein.vim')

  call s:dein_load_yaml(g:plugs)

  if isdirectory(expand('$VIMPATH/nvim/dev'))
    call dein#local(expand('$VIMPATH/nvim/dev'), {'frozen': 1, 'merged': 0})
  endif
  call dein#end()
  call dein#save_state()
endif
if dein#check_install()
  if ! has('nvim')
    set nomore
  endif
  call dein#install()
endif

filetype plugin indent on
syntax enable

call dein#call_hook('source')
call dein#call_hook('post_source')
call dein#remote_plugins()
unlet g:plugs
" }

" }

" Theme and UI {
"set t_Co=256 " Enable 256 color term

hi MatchParen cterm=bold term=bold

set termguicolors
let base16colorspace=256
set background=dark
let ayucolor="dark"
colorscheme ayu
autocmd MyAutoCmd ColorScheme * colorscheme ayu

set tabpagemax=15               " Only show 15 tabs
set showmode                    " Display the current mode

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
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set scrolljump=5                " Lines to scroll when cursor leaves screen
set list                        " Show hidden characters
set listchars=tab:›\ ,eol:¬,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
set noshowmode          " Don't show mode in cmd window
set shortmess=aoOTI     " Shorten messages and don't show intro
set scrolloff=2         " Keep at least 2 lines above/below
set sidescrolloff=5     " Keep at least 5 lines left/right
set noruler             " Disable default status ruler

set showtabline=2       " Always show the tabs line
set winwidth=30         " Minimum width for active window
set winheight=1         " Minimum height for active window
set pumheight=15        " Pop-up menu's line height
set helpheight=12       " Minimum help window height
set previewheight=12    " Completion preview height

set noshowcmd           " Don't show command in status line
set cmdheight=1         " Height of the command line
set cmdwinheight=5      " Command-line lines
set equalalways         " Resize windows on split or close
set laststatus=2        " Always show a status line
set colorcolumn=120     " Highlight the 80th character limit
set display=lastline

" Do not display completion messages
" Patch: https://groups.google.com/forum/#!topic/vim_dev/WeBBjkXE8H8
if has('patch-7.4.314')
  set shortmess+=c
endif

" Do not display message when editing files
if has('patch-7.4.1570')
  set shortmess+=F
endif

" For snippet_complete marker
if has('conceal') && v:version >= 703
  set conceallevel=2 concealcursor=niv
endif
" }

" General Settings {

" - General {
set mouse=nv                 " Disable mouse in command-line mode
set modeline                 " automatically setting options from modelines
set report=0                 " Don't report on line changes
set errorbells               " Trigger bell on error
set visualbell               " Use visual bell instead of beeping
set hidden                   " hide buffers when abandoned instead of unload
set fileformats=unix,dos,mac " Use Unix as the standard file type
set magic                    " For regular expressions turn magic on
set path=.,**                " Directories to search when using gf
set virtualedit=block        " Position cursor anywhere in visual block
set synmaxcol=1000           " Don't syntax highlight long lines
set formatoptions+=1         " Don't break lines after a one-letter word
set formatoptions-=t         " Don't auto-wrap text
if has('patch-7.3.541')
  set formatoptions+=j       " Remove comment leader when joining lines
endif

if has('vim_starting')
  set encoding=utf-8
  scriptencoding utf-8
endif

" What to save for views:
set viewoptions-=options
set viewoptions+=slash,unix

" What to save in sessions:
set sessionoptions-=blank
set sessionoptions-=options
set sessionoptions-=globals
set sessionoptions-=folds
set sessionoptions-=help
set sessionoptions-=buffers
set sessionoptions+=tabpages

if has('clipboard')
  set clipboard& clipboard+=unnamedplus
endif
" }

" - Wildmenu {
set wildmenu
set wildmode=list:longest,full
set wildignore=*.pyc,*.o,*.lo,*.la,*.exe,*.swp,*.db,*.bak,*.old,*.dat,*.,tmp,*.mdb,*~,~*
set wildoptions=tagfile
set wildignorecase
set wildignore+=.git,.hg,.svn,.stversions,*.pyc,*.spl,*.o,*.out,*~,%*
set wildignore+=*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store
set wildignore+=**/node_modules/**,**/bower_modules/**,*/.sass-cache/*
set wildignore+=*/nginx_runtime/*,*/build/*,*/logs/*,*/dist/*,*/tmp/*
set wildignore+=__pycache__,*.egg-info
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=*.log,*.pyc,*.sqlite,*.sqlite3,*.min.js,*.min.css,*.tags
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz
set wildignore+=*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso
set wildignore+=*.pdf,*.dmg,*.app,*.ipa,*.apk,*.mobi,*.epub
set wildignore+=*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc
set wildignore+=*.ppt,*.pptx,*.doc,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps
set wildignore+=*/.git/*,*/.svn/*,*.DS_Store
" }

" - Tabs and Indents {
set textwidth=120   " Text width maximum chars before wrapping
set noexpandtab     " Don't expand tabs to spaces.
set tabstop=2       " The number of spaces a tab is
set softtabstop=2   " While performing editing operations
set shiftwidth=2    " Number of spaces to use in auto(indent)
set smarttab        " Tab insert blanks according to 'shiftwidth'
set autoindent      " Use same indenting on new lines
set smartindent     " Smart autoindenting on new lines
set shiftround      " Round indent to multiple of 'shiftwidth'
" }

" - Timing {
set timeout ttimeout
set timeoutlen=750  " Time out on mappings
set updatetime=300  " Idle time to write swap and trigger CursorHold

" Time out on key codes
set ttimeoutlen=10
" }

" - Searching {
set ignorecase      " Search ignoring case
set smartcase       " Keep case when searching with *
set infercase       " Adjust case in insert completion mode
set wrapscan        " Searches wrap around the end of the file
set showmatch       " Jump to matching bracket
set matchpairs+=<:> " Add HTML brackets to pair matching
set matchtime=1     " Tenths of a second to show the matching paren
set cpoptions-=m    " showmatch will wait 0.5s or until a char is typed
" }

" - Behavior {
set nowrap                      " No wrap by default
set linebreak                   " Break long lines at 'breakat'
set breakat=\ \	;:,!?           " Long lines break chars
set nostartofline               " Cursor in same column for few commands
set whichwrap+=h,l,<,>,[,],~    " Move to following line on certain keys
set splitbelow splitright       " Splits open bottom right
set switchbuf=useopen,usetab    " Jump to the first open window in any tab
set switchbuf+=vsplit           " Switch buffer behavior to vsplit
set backspace=indent,eol,start  " Intuitive backspacing in insert mode
set diffopt=filler,iwhite       " Diff mode: show fillers, ignore white
set showfulltag                 " Show tag and tidy search in completion
set complete=.                  " No wins, buffs, tags, include scanning

if exists('+inccommand')
  set inccommand=nosplit
endif
" }

" - Folds {
" FastFold https://github.com/Shougo/shougo-s-github
autocmd MyAutoCmd TextChangedI,TextChanged *
  \ if &l:foldenable && &l:foldmethod !=# 'manual' |
  \   let b:foldmethod_save = &l:foldmethod |
  \   let &l:foldmethod = 'manual' |
  \ endif

autocmd MyAutoCmd BufWritePost *
  \ if &l:foldmethod ==# 'manual' && exists('b:foldmethod_save') |
  \   let &l:foldmethod = b:foldmethod_save |
  \   execute 'normal! zx' |
  \ endif

if has('folding')
  set foldenable
  set foldmethod=syntax
  set foldlevelstart=99
  set foldtext=FoldText()
endif

" Improved Vim fold-text
" See: http://www.gregsexton.org/2011/03/improving-the-text-displayed-in-a-fold/
function! FoldText()
  " Get first non-blank line
  let fs = v:foldstart
  while getline(fs) =~? '^\s*$' | let fs = nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
    let line = getline(v:foldstart)
  else
    let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif

  let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
  let foldSize = 1 + v:foldend - v:foldstart
  let foldSizeStr = ' ' . foldSize . ' lines '
  let foldLevelStr = repeat('+--', v:foldlevel)
  let lineCount = line('$')
  let foldPercentage = printf('[%.1f', (foldSize*1.0)/lineCount*100) . '%] '
  let expansionString = repeat('.', w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
  return line . expansionString . foldSizeStr . foldPercentage . foldLevelStr
endfunction
" }

" }

" Load other modules {
call s:source_file('terminal.vim')
call s:source_file('filetype.vim')
call s:source_file('mappings.vim')
set secure
" }

if s:is_sudo
  set noswapfile
  set nobackup
  set nowritebackup
  set noundofile
  if has('nvim')
    set shada="NONE"
  else
    set viminfo="NONE"
  endif
endif
