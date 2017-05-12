" Deoplete {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

" General Settings {
augroup deoplete
  au!
  autocmd CompleteDone * pclose!
augroup END
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete_delay = 60
let g:deoplete#auto_refresh_delay = 1000
let g:deoplete#enable_camel_case = 1
let g:deoplete#tag#cache_limit_size = 5000000
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
call deoplete#custom#set('buffer',        'mark', 'Ω')
call deoplete#custom#set('tag',           'mark', '⋆')
call deoplete#custom#set('omni',          'mark', '⊚')
call deoplete#custom#set('ternjs',        'mark', '⩫')
call deoplete#custom#set('jedi',          'mark', '⩫')
call deoplete#custom#set('vim',           'mark', '⩫')
call deoplete#custom#set('neosnippet',    'mark', '⊕')
call deoplete#custom#set('around',        'mark', '⮀')
call deoplete#custom#set('syntax',        'mark', '♯')
call deoplete#custom#set('tmux-complete', 'mark', '┼')

call deoplete#custom#set('vim',           'rank', 620)
call deoplete#custom#set('jedi',          'rank', 610)
call deoplete#custom#set('omni',          'rank', 600)
call deoplete#custom#set('neosnippet',    'rank', 510)
call deoplete#custom#set('member',        'rank', 500)
call deoplete#custom#set('file_include',  'rank', 420)
call deoplete#custom#set('file',          'rank', 410)
call deoplete#custom#set('tag',           'rank', 400)
call deoplete#custom#set('around',        'rank', 330)
call deoplete#custom#set('buffer',        'rank', 320)
call deoplete#custom#set('dictionary',    'rank', 310)
call deoplete#custom#set('tmux-complete', 'rank', 300)
call deoplete#custom#set('syntax',        'rank', 200)

" }

" Matchers and Converters " {
" Default sorters: ['sorter_rank']
" Default matchers: ['matcher_length', 'matcher_fuzzy']

call deoplete#custom#set('_', 'converters', [
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
