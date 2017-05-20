" Denite {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }


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


nnoremap [denite] <Nop>
exe 'nmap '.g:denite_leader.' [denite]'

nnoremap <silent> [denite]r  :<C-u>Denite -resume<CR>
nnoremap <silent> [denite]p  :<C-u>Denite buffer file_rec<CR>
nnoremap <silent> <C-p>     :<C-u>Denite buffer file_rec<CR>
nnoremap <silent> [denite]n  :<C-u>Denite dein -no-quit<CR>
nnoremap <silent> [denite]f  :<C-u>Denite grep -buffer-name=grep<CR>
