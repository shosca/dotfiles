" Vim syntax file
" Language:		Brail

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

if !exists("main_syntax")
    let main_syntax = 'boo'
endif

if version < 600
    so <sfile>:p:h/html.vim
    syn include @boo <sfile>:p:h/boo.vim
else
    runtime! syntax/html.vim
    unlet b:current_syntax
    syn include @boo syntax/boo.vim
endif

syn cluster htmlPreproc add=BrailInsideHtmlTags

syn keyword booConditional	if else elif end component section
hi link booConditional Conditional

syn case ignore

" <% ... %> highlighting
syn region BrailInsideHtmlTags keepend matchgroup=Delimiter start=+<%+ end=+%>+ contains=@boo

let b:current_syntax = "brail"
