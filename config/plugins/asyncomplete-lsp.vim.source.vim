nnoremap <leader>d :LspDefinition<CR>
nnoremap <leader>K :LspHover<CR>
nnoremap <leader>n :LspReferences<CR>
nnoremap <leader>r :LspRename<CR>

au User lsp_setup call lsp#register_server({
      \ 'name': 'python',
      \ 'cmd': {server_info->['pyls']},
      \ 'whitelist': ['python']})

au User lsp_setup call lsp#register_server({
      \ 'name': 'clangd',
      \ 'cmd': {server_info->['clangd']},
      \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
      \ })

au User lsp_setup call lsp#register_server({
      \ 'name': 'css-languageserver',
      \ 'cmd': {server_info->[&shell, &shellcmdflag, 'css-languageserver --stdio']},
      \ 'whitelist': ['css', 'less', 'sass'],
      \ })

au User lsp_setup call lsp#register_server({
      \ 'name': 'go-langserver',
      \ 'cmd': {server_info->['go-langserver', '-mode', 'stdio']},
      \ 'whitelist': ['go'],
      \ })

au User lsp_setup call lsp#register_server({
      \ 'name': 'js',
      \ 'cmd': {server_info->['javascript-typescript-stdio']},
      \ 'whitelist': ['javascript', 'javascript.jsx', 'jsx']})

au User lsp_setup call lsp#register_server({
      \ 'name': 'typescript-language-server',
      \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
      \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
      \ 'whitelist': ['typescript'],
      \ })

au User lsp_setup call lsp#register_server({
      \ 'name': 'rust',
      \ 'cmd': {server_info->['rustup', 'run', 'nightly', 'rls']},
      \ 'whitelist': ['rust', 'rs']})

au User lsp_setup call lsp#register_server({
      \ 'name': 'sh',
      \ 'cmd': {server_info->['bash-language-server']},
      \ 'whitelist': ['sh', 'bash', 'zsh']})

au User lsp_setup call lsp#register_server({
      \ 'name': 'docker-langserver',
      \ 'cmd': {server_info->[&shell, &shellcmdflag, 'docker-langserver --stdio']},
      \ 'whitelist': ['dockerfile'],
      \ })
