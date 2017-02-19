
" Plugins {

    " Unite {
    call dein#add('k0kubun/unite-git-files')
    call dein#add('Shougo/neoyank.vim')
    call dein#add('Shougo/unite-build')
    call dein#add('tsukkee/unite-tag')
    call dein#add('thinca/vim-unite-history')
    call dein#add('Shougo/neomru.vim')
    " }

    " General {
    call dein#add('mhinz/vim-startify') "{
        let g:startify_session_dir = $XDG_DATA_HOME . '/nvim/session'
    " }
    call dein#add('Shougo/vimfiler.vim')
    call dein#add('epeli/slimux', {
        \ 'hook_add': join([
        \   'map <C-c><C-c> :SlimuxREPLSendLine<CR>',
        \   'vmap <C-c><C-c> :SlimuxREPLSendSelection<CR>',
        \   'map <Leader>s :SlimuxREPLSendLine<CR>',
        \   'vmap <Leader>s :SlimuxREPLSendSelection<CR>',
        \   'map <Leader>sa :SlimuxShellLast<CR>',
        \   'map <Leader>sk :SlimuxSendKeysLast<CR>',
        \ ], "\n")
        \ })
    call dein#add('Konfekt/FastFold', {
        \ 'on_event': 'BufEnter',
        \ 'hook_post_source': 'FastFoldUpdate'
        \ })
    call dein#add('easymotion/vim-easymotion')
    call dein#add('vim-scripts/sessionman.vim', {
        \ 'hook_add': join([
        \   'nmap <leader>sl :SessionList<CR>',
        \   'nmap <leader>ss :SessionSave<CR>',
        \   'nmap <leader>sc :SessionClose<CR>',
        \ ], "\n")
        \ })
    call dein#add('Shougo/neoinclude.vim')
    call dein#add('Shougo/context_filetype.vim')
    " }

    " Programming {

        " General {

            " Git {
            call dein#add('tpope/vim-fugitive')
            call dein#add('cohama/agit.vim', {'on_cmd':['Agit', 'AgitFile']})
            call dein#add('gregsexton/gitv', {'on_cmd':['Gitv']})
            call dein#add('lambdalisue/vim-gita', {'on_cmd':['Gita']})
            call dein#add('junegunn/gv.vim', {'on_cmd':['GV']})
            call dein#add('airblade/vim-gitgutter') " {
                let g:gitgutter_enabled = 1
                let g:gitgutter_eager = 0
                let g:gitgutter_map_keys = 0
                " }
            " }

        call dein#add('romainl/vim-qf')
        call dein#add('vim-scripts/vim-pipe')
        call dein#add('sbdchd/neoformat.git')
        call dein#add('joonty/vdebug')

        call dein#add('w0rp/ale.git', {
            \ 'hook_add': join([
            \   'nmap <silent> <C-k> <Plug>(ale_previous_wrap)',
            \   'nmap <silent> <C-j> <Plug>(ale_next_wrap)',
            \ ], "\n")
            \ })
        call dein#add('scrooloose/nerdcommenter')
        call dein#add('godlygeek/tabular', {
            \ 'hook_add': join([
            \   'nmap <Leader>a& :Tabularize /&<CR>',
            \   'vmap <Leader>a& :Tabularize /&<CR>',
            \   'nmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>',
            \   'vmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>',
            \   'nmap <Leader>a=> :Tabularize /=><CR>',
            \   'vmap <Leader>a=> :Tabularize /=><CR>',
            \   'nmap <Leader>a: :Tabularize /:<CR>',
            \   'vmap <Leader>a: :Tabularize /:<CR>',
            \   'nmap <Leader>a:: :Tabularize /:\zs<CR>',
            \   'vmap <Leader>a:: :Tabularize /:\zs<CR>',
            \   'nmap <Leader>a, :Tabularize /,<CR>',
            \   'vmap <Leader>a, :Tabularize /,<CR>',
            \   'nmap <Leader>a,, :Tabularize /,\zs<CR>',
            \   'vmap <Leader>a,, :Tabularize /,\zs<CR>',
            \   'nmap <Leader>a<Bar> :Tabularize /<Bar><CR>',
            \   'vmap <Leader>a<Bar> :Tabularize /<Bar><CR>',
            \ ], "\n")
            \ })
        call dein#add('luochen1990/rainbow') " {
            let g:rainbow_active=1
            let g:rainbow_load_separately = [
                \ [ '*' , [['(', ')'], ['\[', '\]'], ['{', '}']]  ],
                \ [ '*.tex' , [['(', ')'], ['\[', '\]']]  ],
                \ [ '*.cpp' , [['(', ')'], ['\[', '\]'], ['{', '}']]  ],
                \ [ '*.{html,htm}' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']]  ],
            \ ]
            let g:rainbow_guifgs = ['RoyalBlue3', 'DarkOrange3', 'DarkOrchid3', 'FireBrick']
            let g:rainbow_ctermfgs = ['lightblue', 'lightgreen', 'yellow', 'red', 'magenta']
            " }
        call dein#add('matchit.zip')
        call dein#add('tpope/vim-surround')
        call dein#add('jiangmiao/auto-pairs')
        " }

        " Ruby {
        call dein#add('fishbullet/deoplete-ruby', {'on_ft': 'ruby'})
        call dein#add('tpope/vim-rails', {'on_ft': 'ruby'})
        " }

        " Javascript {

        call dein#add('elzr/vim-json', {
            \ 'on_ft': 'json',
            \ 'hook_source': 'let g:vim_json_syntax_conceal = 0'
            \ })
        call dein#add('groenewege/vim-less')
        call dein#add('pangloss/vim-javascript', {'on_ft': 'javascript'})
        call dein#add('briancollins/vim-jst')
        call dein#add('kchmck/vim-coffee-script', {'on_ft': 'coffee'})
        call dein#add('mxw/vim-jsx')
        call dein#add('carlitux/deoplete-ternjs', {'on_ft': 'javascript'})
        " }

        " HTML {
        call dein#add('hail2u/vim-css3-syntax')
        call dein#add('tpope/vim-haml')
        " }

        " Puppet {
        call dein#add('rodjek/vim-puppet')
        " }

        " Rust {
        call dein#add('rust-lang/rust.vim')
        call dein#add('racer-rust/vim-racer')
        call dein#add('sebastianmarkow/deoplete-rust')
        " }

        " Go Lang {
        call dein#add('fatih/vim-go', {
            \ 'on_ft': 'go',
            \ 'hook_source': join([
            \   'let g:go_highlight_functions = 1',
            \   'let g:go_highlight_methods = 1',
            \   'let g:go_highlight_structs = 1',
            \   'let g:go_highlight_operators = 1',
            \   'let g:go_highlight_build_constraints = 1',
            \   'let g:go_fmt_command = "goimports"',
            \ ], " \n "),
            \ 'hook_add': join([
            \   'au FileType go nmap <Leader>s <Plug>(go-implements)',
            \   'au FileType go nmap <Leader>i <Plug>(go-info)',
            \   'au FileType go nmap <Leader>e <Plug>(go-rename)',
            \   'au FileType go nmap <leader>r <Plug>(go-run)',
            \   'au FileType go nmap <leader>b <Plug>(go-build)',
            \   'au FileType go nmap <leader>t <Plug>(go-test)',
            \   'au FileType go nmap <Leader>gd <Plug>(go-doc)',
            \   'au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)',
            \   'au FileType go nmap <leader>co <Plug>(go-coverage)',
            \ ], " \n ")
            \ })
        " }

    " }

" }

