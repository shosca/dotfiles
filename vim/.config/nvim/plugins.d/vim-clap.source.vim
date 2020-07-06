nnoremap <silent><LocalLeader>f :<C-u>Clap! files<CR>
nnoremap <silent><LocalLeader>b :<C-u>Clap! buffers<CR>
nnoremap <silent><LocalLeader>g :<C-u>Clap! grep<CR>
nnoremap <silent><LocalLeader>j :<C-u>Clap! jumps<CR>
nnoremap <silent><LocalLeader>h :<C-u>Clap! help_tags<CR>
nnoremap <silent><LocalLeader>t :<C-u>Clap! tags<CR>
nnoremap <silent><LocalLeader>l :<C-u>Clap! loclist<CR>
nnoremap <silent><LocalLeader>q :<C-u>Clap! quickfix<CR>
nnoremap <silent><LocalLeader>m :<C-u>Clap! files ~/docs/books<CR>
nnoremap <silent><LocalLeader>y :<C-u>Clap! yanks<CR>
nnoremap <silent><LocalLeader>/ :<C-u>Clap! lines<CR>
nnoremap <silent><LocalLeader>* :<C-u>Clap! lines ++query=<cword><CR>
nnoremap <silent><LocalLeader>; :<C-u>Clap! command_history<CR>

nnoremap <silent><Leader>gl :<C-u>Clap! commits<CR>
nnoremap <silent><Leader>gt :<C-u>Clap! tags ++query=<cword><CR>
xnoremap <silent><Leader>gt :<C-u>Clap! tags ++query=@visual<CR><CR>
nnoremap <silent><Leader>gf :<C-u>Clap! files ++query=<cword><CR>
xnoremap <silent><Leader>gf :<C-u>Clap! files ++query=@visual<CR><CR>
nnoremap <silent><Leader>gg :<C-u>Clap! grep ++query=<cword><CR>
xnoremap <silent><Leader>gg :<C-u>Clap! grep ++query=@visual<CR><CR>

autocmd user_events FileType clap_input call s:clap_mappings()

function! s:clap_mappings()
  nnoremap <silent> <buffer> <nowait>' :call clap#handler#tab_action()<CR>
  inoremap <silent> <buffer> <Tab>   <C-R>=clap#navigation#linewise('down')<CR>
  inoremap <silent> <buffer> <S-Tab> <C-R>=clap#navigation#linewise('up')<CR>
  nnoremap <silent> <buffer> <C-d> :<c-u>call clap#navigation#scroll('down')<CR>
  nnoremap <silent> <buffer> <C-u> :<c-u>call clap#navigation#scroll('up')<CR>
endfunction
