
let g:NERDTreeMapOpenSplit = 'sv'
let g:NERDTreeMapOpenVSplit = 'sg'
let g:NERDTreeMapOpenInTab = 'st'
let g:NERDTreeMapOpenInTabSilent = 'sT'
let g:NERDTreeMapUpdirKeepOpen = '<BS>'
let g:NERDTreeMapOpenRecursively = 't'
let g:NERDTreeMapCloseChildren = 'T'
let g:NERDTreeMapToggleHidden = '.'

let g:NERDTreeIndicatorMapCustom = {
	\ 'Modified':  '',
	\ 'Staged':    'ᴍ',
	\ 'Untracked': '⁇',
	\ 'Renamed':   '',
	\ 'Unmerged':  '',
	\ 'Deleted':   '',
	\ 'Dirty':     '·',
	\ 'Clean':     '✓',
	\ 'Unknown':   '?'
	\ }

let g:NERDTreeDirArrowExpandable = '▷'
let g:NERDTreeDirArrowCollapsible = '▼'

highlight! NERDTreeOpenable ctermfg=132 guifg=#B05E87
highlight! def link NERDTreeClosable NERDTreeOpenable

highlight! NERDTreeFile ctermfg=246 guifg=#999999
highlight! NERDTreeExecFile ctermfg=246 guifg=#999999

highlight! clear NERDTreeFlags
highlight! NERDTreeFlags ctermfg=234 guifg=#1d1f21
highlight! NERDTreeCWD ctermfg=240 guifg=#777777

highlight! NERDTreeGitStatusModified ctermfg=1 guifg=#D370A3
highlight! NERDTreeGitStatusStaged ctermfg=10 guifg=#A3D572
highlight! NERDTreeGitStatusUntracked ctermfg=12 guifg=#98CBFE
highlight! def link NERDTreeGitStatusRenamed Title
highlight! def link NERDTreeGitStatusUnmerged Label
highlight! def link NERDTreeGitStatusDirDirty Constant
highlight! def link NERDTreeGitStatusDirClean DiffAdd
highlight! def link NERDTreeGitStatusUnknown Comment

function! s:NERDTreeHighlight()
  for l:name in keys(g:NERDTreeIndicatorMapCustom)
    let l:icon = g:NERDTreeIndicatorMapCustom[l:name]
    if empty(l:icon)
      continue
    endif
    let l:prefix = index(['Dirty', 'Clean'], l:name) > -1 ? 'Dir' : ''
    let l:hiname = escape('NERDTreeGitStatus'.l:prefix.l:name, '~')
    execute 'syntax match '.l:hiname.' #'.l:icon.'# containedin=NERDTreeFlags'
  endfor

  syntax match NERDTreeOpenBracket /\[/
        \ contained containedin=NERDTreeFlags conceal
endfunction

augroup AddHighlighting
	autocmd!
	autocmd FileType nerdtree call s:NERDTreeHighlight()
augroup END

