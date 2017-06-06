" denite.nvim
" -----------

" INTERFACE
call denite#custom#option('default', 'prompt', 'λ:')
call denite#custom#option('default', 'vertical_preview', 1)
call denite#custom#option('default', 'short_source_names', 1)

call denite#custom#option('grep', 'empty', 0)
call denite#custom#option('grep', 'vertical_preview', 1)
"call denite#custom#option('grep', 'auto_highlight', 1)

call denite#custom#option('list', 'mode', 'normal')
call denite#custom#option('list', 'winheight', 10)

" MATCHERS
let s:matchers = ['matcher_fuzzy']
if &runtimepath =~# 'cpsm'
  let s:matchers = ['matcher_cpsm', 'matcher_fuzzy']
endif

call denite#custom#source('file_mru,file_old,file_rec,grep', 'matchers', s:matchers)

call denite#custom#source('mark', 'matchers', ['matcher_fuzzy', 'matcher_project_files'])

" CONVERTERS
call denite#custom#source('file_mru,file_old,mark', 'converters', ['converter_relative_word'])

" FIND and GREP COMMANDS
if executable('rg')
  " ripgrep
  call denite#custom#var('file_rec', 'command',
        \ ['rg', '--files', '--glob', '!.git'])
  call denite#custom#var('grep', 'command', ['rg'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'default_opts',
        \ ['--vimgrep', '--no-heading'])
elseif executable('ag')
  " The Silver Searcher
  call denite#custom#var('file_rec', 'command',
        \ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])

  call denite#custom#var('grep', 'command', ['ag'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', [])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'default_opts',
        \ [ '--vimgrep', '--smart-case' ])

elseif executable('ack')
  " Ack command
  call denite#custom#var('grep', 'command', ['ack'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', ['--match'])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'default_opts',
        \ ['--ackrc', $HOME.'/.config/ackrc', '-H',
        \ '--nopager', '--nocolor', '--nogroup', '--column'])
endif

" KEY MAPPINGS
let insert_mode_mappings = [
      \ ['<C-j>', '<denite:move_to_next_line>', 'noremap'],
      \ ['<C-k>', '<denite:move_to_previous_line>', 'noremap'],
  \ ]

let normal_mode_mappings = [
      \ ['<r>', '<denite:do_action:quickfix>', 'noremap'],
  \ ]

for m in insert_mode_mappings
  call denite#custom#map('insert', m[0], m[1], m[2])
endfor
for m in normal_mode_mappings
  call denite#custom#map('normal', m[0], m[1], m[2])
endfor

nnoremap <silent><LocalLeader>r :<C-u>Denite -resume<CR>
nnoremap <silent><LocalLeader>f :<C-u>Denite file_rec<CR>
nnoremap <silent><LocalLeader>b :<C-u>Denite buffer file_old -default-action=switch<CR>
nnoremap <silent><LocalLeader>d :<C-u>Denite directory_rec -default-action=cd<CR>
nnoremap <silent><LocalLeader>l :<C-u>Denite location_list -buffer-name=list<CR>
nnoremap <silent><LocalLeader>q :<C-u>Denite quickfix -buffer-name=list<CR>
nnoremap <silent><LocalLeader>n :<C-u>Denite dein -no-quit<CR>
nnoremap <silent><LocalLeader>g :<C-u>Denite grep<CR>
nnoremap <silent><LocalLeader>j :<C-u>Denite jump change file_point<CR>
nnoremap <silent><LocalLeader>o :<C-u>Denite outline<CR>
nnoremap <silent><LocalLeader>s :<C-u>Denite session<CR>
nnoremap <silent><LocalLeader>h :<C-u>Denite help<CR>
nnoremap <silent><LocalLeader>m :<C-u>Denite mpc -buffer-name=mpc<CR>
nnoremap <silent><LocalLeader>/ :<C-u>Denite line<CR>
nnoremap <silent><LocalLeader>* :<C-u>DeniteCursorWord line<CR>
nnoremap <silent><LocalLeader>z :<C-u>Denite z<CR>

" chemzqm/denite-git
nnoremap <silent> <Leader>gl :<C-u>Denite gitlog<CR>
nnoremap <silent> <Leader>gs :<C-u>Denite gitstatus<CR>

" Open Denite with word under cursor or selection
nnoremap <silent> <Leader>gf :DeniteCursorWord file_rec<CR>
nnoremap <silent> <Leader>gg :DeniteCursorWord grep<CR>
vnoremap <silent> <Leader>gg :<C-u>call <SID>get_selection('/')<CR> :execute 'Denite grep:::'.@/<CR><CR>

function! s:get_selection(cmdtype)
  let temp = @s
  normal! gv"sy
  let @/ = substitute(escape(@s, '\'.a:cmdtype), '\n', '\\n', 'g')
  let @s = temp
endfunction
