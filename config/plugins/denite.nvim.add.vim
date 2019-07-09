" denite.nvim
" -----------

" INTERFACE
call denite#custom#option('_', {
      \ 'prompt': 'λ:',
      \ 'empty': 0,
      \ 'winheight': 10,
      \ 'source_names': 'short',
      \ 'vertical_preview': 1,
      \ 'auto-accel': 1,
      \ 'auto-resume': 1, 
      \ })
call denite#custom#option('list', {})


" MATCHERS
" default is matcher_fuzzy
call denite#custom#source('tag', 'matchers', ['matcher_substring'])
if has('nvim') && &runtimepath =~# '\/cpsm'
  call denite#custom#source(
        \ 'buffer,file_mru,file_old,file/rec,grep,mpc,line',
        \ 'matchers', ['matcher_cpsm', 'matcher_fuzzy'])
endif

" SORTERS
" default is sorter_rank
call denite#custom#source('z', 'sorters', ['sorter_z'])

" CONVERTERS
" default is none
call denite#custom#source('file_mru,file_old,mark', 'converters', ['converter_relative_word'])

" FIND and GREP COMMANDS
if executable('rg')
  " ripgrep
  call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])
  call denite#custom#var('grep', 'command', ['rg'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'default_opts', ['--vimgrep', '--no-heading'])
elseif executable('ag')
  " The Silver Searcher
  call denite#custom#var('file/rec', 'command', ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
  call denite#custom#var('grep', 'command', ['ag'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', [])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'default_opts', [ '--skip-vcs-ignores', '--vimgrep', '--smart-case' ])
elseif executable('ack')
  " Ack command
  call denite#custom#var('grep', 'command', ['ack'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', ['--match'])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'default_opts', ['--ackrc', $HOME.'/.config/ackrc', '-H', '--nopager', '--nocolor', '--nogroup', '--column'])
endif

nnoremap <silent><LocalLeader>* :<C-u>DeniteCursorWord line<CR>
nnoremap <silent><LocalLeader>/ :<C-u>Denite line<CR>
nnoremap <silent><LocalLeader>; :<C-u>Denite command command_history<CR>
nnoremap <silent><LocalLeader><Space> :<C-u>Denite -resume -refresh -mode=normal<CR>
nnoremap <silent><LocalLeader>b :<C-u>Denite buffer -default-action=switch<CR>
nnoremap <silent><LocalLeader>d :<C-u>Denite directory_rec -default-action=cd<CR>
nnoremap <silent><LocalLeader>f :<C-u>Denite file/rec<CR>
nnoremap <silent><LocalLeader>g :<C-u>Denite grep<CR>
nnoremap <silent><LocalLeader>h :<C-u>Denite help<CR>
nnoremap <silent><LocalLeader>j :<C-u>Denite jump change file_point<CR>
nnoremap <silent><LocalLeader>l :<C-u>Denite location_list -buffer-name=list<CR>
nnoremap <silent><LocalLeader>m :<C-u>call dein#update()<CR>Denite -no-quit -mode=normal dein_log:!<CR>
nnoremap <silent><LocalLeader>n :<C-u>Denite dein -no-quit<CR>
nnoremap <silent><LocalLeader>n :<C-u>Denite dein<CR>
nnoremap <silent><LocalLeader>o :<C-u>Denite outline<CR>
nnoremap <silent><LocalLeader>q :<C-u>Denite quickfix -buffer-name=list<CR>
nnoremap <silent><LocalLeader>v :<C-u>Denite neoyank -buffer-name=register<CR>

xnoremap <silent><LocalLeader>v :<C-u>Denite neoyank -buffer-name=register -default-action=replace<CR>

" chemzqm/denite-git
nnoremap <silent> <Leader>gl :<C-u>Denite gitlog<CR>
nnoremap <silent> <Leader>gs :<C-u>Denite gitstatus<CR>

" Open Denite with word under cursor or selection
nnoremap <silent> <Leader>gt :DeniteCursorWord tag:include -buffer-name=tag -immediately<CR>
nnoremap <silent> <Leader>gf :DeniteCursorWord file/rec<CR>
nnoremap <silent> <Leader>gg :DeniteCursorWord grep<CR>
vnoremap <silent> <Leader>gg :<C-u>call <SID>get_selection('/')<CR> :execute 'Denite grep:::'.@/<CR><CR>

function! s:get_selection(cmdtype)
  let temp = @s
  normal! gv"sy
  let @/ = substitute(escape(@s, '\'.a:cmdtype), '\n', '\\n', 'g')
  let @s = temp
endfunction
