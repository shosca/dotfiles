let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= ' | '
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'setl modeline<'

setlocal iskeyword+=:,#
setlocal keywordprg=:help

" For gf
let &l:path = join(map(split(&runtimepath, ','), 'v:val."/autoload"'), ',')
setlocal suffixesadd=.vim
setlocal includeexpr=fnamemodify(substitute(v:fname,'#','/','g'),':h')

let &cpoptions = s:save_cpo

setlocal expandtab
setlocal foldlevel=0
setlocal shiftwidth=2
setlocal spell
setlocal tabstop=2
setlocal textwidth=120
