" Deoplete {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

" General Settings {
let g:deoplete#enable_refresh_always = 0
let g:deoplete#enable_camel_case = 1
let g:deoplete#max_abbr_width = 35
let g:deoplete#max_menu_width = 20
let g:deoplete#skip_chars = ['(', ')', '<', '>']
let g:deoplete#tag#cache_limit_size = 800000
let g:deoplete#file#enable_buffer_path = 1
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menu,preview,longest
" }

" Omni functions and patterns " {
" ---
let g:deoplete#omni#functions = get(g:, 'deoplete#omni#functions', {})
let g:deoplete#omni#functions.php = 'phpcomplete_extended#CompletePHP'
let g:deoplete#omni#functions.css = 'csscomplete#CompleteCSS'
let g:deoplete#omni#functions.html = 'htmlcomplete#CompleteTags'
let g:deoplete#omni#functions.markdown = 'htmlcomplete#CompleteTags'

let g:deoplete#omni_patterns = get(g:, 'deoplete#omni_patterns', {})
let g:deoplete#omni_patterns.html = '<[^>]*'

let g:deoplete#omni#input_patterns = get(g:, 'deoplete#omni#input_patterns', {})
let g:deoplete#omni#input_patterns.xml = '<[^>]*'
let g:deoplete#omni#input_patterns.md = '<[^>]*'
let g:deoplete#omni#input_patterns.css  = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
let g:deoplete#omni#input_patterns.scss = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
let g:deoplete#omni#input_patterns.sass = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
let g:deoplete#omni#input_patterns.python = ''
let g:deoplete#omni#input_patterns.javascript = ''
let g:deoplete#omni#input_patterns.php = '\w+|[^. \t]->\w*|\w+::\w*'

" }

" Ranking and Marks " {
" Default rank is 100, higher is better.
call deoplete#custom#source('buffer',        'mark', 'Ω')
call deoplete#custom#source('tag',           'mark', '⋆')
call deoplete#custom#source('omni',          'mark', '⊚')
call deoplete#custom#source('ternjs',        'mark', '⩫')
call deoplete#custom#source('jedi',          'mark', '⩫')
call deoplete#custom#source('vim',           'mark', '⩫')
call deoplete#custom#source('neosnippet',    'mark', '⊕')
call deoplete#custom#source('around',        'mark', '⮀')
call deoplete#custom#source('syntax',        'mark', '♯')
call deoplete#custom#source('tmux-complete', 'mark', '┼')

call deoplete#custom#source('vim',           'rank', 620)
call deoplete#custom#source('jedi',          'rank', 610)
call deoplete#custom#source('omni',          'rank', 600)
call deoplete#custom#source('neosnippet',    'rank', 510)
call deoplete#custom#source('member',        'rank', 500)
call deoplete#custom#source('file_include',  'rank', 420)
call deoplete#custom#source('file',          'rank', 410)
call deoplete#custom#source('tag',           'rank', 400)
call deoplete#custom#source('around',        'rank', 330)
call deoplete#custom#source('buffer',        'rank', 320)
call deoplete#custom#source('dictionary',    'rank', 310)
call deoplete#custom#source('tmux-complete', 'rank', 300)
call deoplete#custom#source('syntax',        'rank', 200)

" }

" Matchers and Converters " {
" Default sorters: ['sorter_rank']
" Default matchers: ['matcher_length', 'matcher_fuzzy']

call deoplete#custom#source('_', 'converters', [
	\ 'converter_remove_paren',
	\ 'converter_remove_overlap',
	\ 'converter_truncate_abbr',
	\ 'converter_truncate_menu',
	\ 'converter_auto_delimiter',
	\ ])
" }

" Key-mappings " {
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col-1] =~ '\s'
endfunction
imap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ deoplete#mappings#manual_complete()
" }
