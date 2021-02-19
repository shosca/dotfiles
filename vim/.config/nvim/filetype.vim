
" File-type Detection
" ------------------------------------------------

if exists('did_load_filetypes')
  finish
endif

augroup filetypedetect

  autocmd BufNewFile,BufRead *.feature,*.story        setfiletype cucumber
  autocmd BufNewFile,BufRead *.j2                     setfiletype jinja
  autocmd BufNewFile,BufRead *.js.map                 setfiletype json
  autocmd BufNewFile,BufRead *.postman_collection     setfiletype json
  autocmd BufNewFile,BufRead *.{feature,story}        setfiletype cucumber
  autocmd BufNewFile,BufRead */.kube/config           setfiletype yaml
  autocmd BufNewFile,BufRead */inventory/*.ini        setfiletype ansible_hosts
  autocmd BufNewFile,BufRead */playbooks/*.{yml,yaml} setfiletype yaml.ansible
  autocmd BufNewFile,BufRead */playbooks/*/*.yml      setfiletype ansible
  autocmd BufNewFile,BufRead */templates/*.{yaml,tpl} setfiletype yaml.gotexttmpl
  autocmd BufNewFile,BufRead .babelrc                 setfiletype json
  autocmd BufNewFile,BufRead .buckconfig              setfiletype toml
  autocmd BufNewFile,BufRead .eslintrc                setfiletype json
  autocmd BufNewFile,BufRead .flowconfig              setfiletype ini
  autocmd BufNewFile,BufRead .jsbeautifyrc            setfiletype json
  autocmd BufNewFile,BufRead .jscsrc                  setfiletype json
  autocmd BufNewFile,BufRead .mk                      setfiletype make
  autocmd BufNewFile,BufRead .tern-project            setfiletype json
  autocmd BufNewFile,BufRead .tern-{project,port}     setfiletype json
  autocmd BufNewFile,BufRead .watchmanconfig          setfiletype json
  autocmd BufNewFile,BufRead Jenkinsfile              setfiletype groovy
  autocmd BufNewFile,BufRead Tmuxfile,tmux/config     setfiletype tmux
  autocmd BufNewFile,BufRead Tmuxfile,tmux/config     setfiletype tmux
  autocmd BufNewFile,BufRead yarn.lock                setfiletype yaml
  autocmd BufNewFile,BufRead poetry.lock              setfiletype toml

augroup END

" Reload vim config automatically {
"execute 'autocmd user_events BufWritePost '.$VIMPATH.'/config/*,vimrc nested'
"      \ .' source $MYVIMRC | redraw | silent doautocmd ColorScheme'
" }

augroup user_events " {

  " Highlight current line only on focused window
  "autocmd WinEnter,InsertLeave * set cursorline
  "autocmd WinLeave,InsertEnter * set nocursorline

  " Automatically set read-only for files being edited elsewhere
  autocmd SwapExists * nested let v:swapchoice = 'o'

  " Check if file changed when its window is focus, more eager than 'autoread'
  autocmd WinEnter,FocusGained * checktime

  " Update filetype on save if empty
  autocmd BufWritePost * nested
        \ if &l:filetype ==# '' || exists('b:ftdetect')
        \ |   unlet! b:ftdetect
        \ |   filetype detect
        \ | endif

  " Reload Vim script automatically if setlocal autoread
  autocmd BufWritePost,FileWritePost *.vim nested
        \ if &l:autoread > 0 | source <afile> |
        \   echo 'source '.bufname('%') |
        \ endif

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  autocmd BufReadPost *
        \ if &ft !~ '^git\c' && ! &diff && line("'\"") > 0 && line("'\"") <= line("$")
        \ |   execute 'normal! g`"zvzz'
        \ | endif

  " Disable paste and/or update diff when leaving insert mode
  autocmd InsertLeave *
        \ if &paste | setlocal nopaste mouse=a | echo 'nopaste' | endif |
        \ if &l:diff | diffupdate | endif

  autocmd TabLeave * let g:lasttab = tabpagenr()

  autocmd FileType crontab setlocal nobackup nowritebackup

	autocmd FileType docker-compose setlocal expandtab

  autocmd FileType gitcommit setlocal spell

  autocmd FileType gitcommit,qfreplace setlocal nofoldenable

  " https://webpack.github.io/docs/webpack-dev-server.html#working-with-editors-ides-supporting-safe-write
  autocmd FileType html,css,javascript,jsx,javascript.jsx setlocal backupcopy=yes

  autocmd FileType zsh setlocal foldenable foldmethod=marker

  autocmd FileType html setlocal path+=./;/

  autocmd FileType markdown
        \ setlocal spell expandtab autoindent
        \ formatoptions=tcroqn2 comments=n:>

  autocmd FileType apache setlocal path+=./;/

  autocmd FileType cam setlocal nonumber synmaxcol=10000

  autocmd FileType go highlight default link goErr WarningMsg |
        \ match goErr /\<err\>/

augroup END " }

let g:python_highlight_all = 1
