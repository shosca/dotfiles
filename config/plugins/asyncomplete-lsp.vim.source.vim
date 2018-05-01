nnoremap <leader>d :LspDefinition<CR>
nnoremap <leader>K :LspHover<CR>
nnoremap <leader>n :LspReferences<CR>
nnoremap <leader>r :LspRename<CR>

au User lsp_setup call lsp#register_server({'name': 'python',
                                          \ 'cmd': {server_info->['pyls']},
                                          \ 'whitelist': ['python']})
au User lsp_setup call lsp#register_server({'name': 'c',
                                          \ 'cmd': {server_info->['clangd']},
                                          \ 'whitelist': ['c', 'cpp']})
au User lsp_setup call lsp#register_server({'name': 'css',
                                          \ 'cmd': {server_info->['css-languageserver']},
                                          \ 'whitelist': ['css', 'less', 'scss']})
au User lsp_setup call lsp#register_server({'name': 'go',
                                          \ 'cmd': {server_info->['go-langserver']},
                                          \ 'whitelist': ['go']})
au User lsp_setup call lsp#register_server({'name': 'js',
                                          \ 'cmd': {server_info->['javascript-typescript-stdio']},
                                          \ 'whitelist': ['javascript', 'javascript.jsx', 'jsx', 'ts', 'typescript']})
au User lsp_setup call lsp#register_server({'name': 'rust',
                                          \ 'cmd': {server_info->['rustup', 'run', 'nightly', 'rls']},
                                          \ 'whitelist': ['rust', 'rs']})
au User lsp_setup call lsp#register_server({'name': 'sh',
                                          \ 'cmd': {server_info->['bash-language-server']},
                                          \ 'whitelist': ['sh', 'bash', 'zsh']})
