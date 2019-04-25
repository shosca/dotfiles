nnoremap <leader>d :call LanguageClient#textDocument_definition()<CR>
nnoremap <leader>K :call LanguageClient#textDocument_hover()<CR>
nnoremap <leader>n :call LanguageClient_textDocument_references()<CR>
nnoremap <leader>r :call LanguageClient#textDocument_rename()<CR>

let g:LanguageClient_settingsPath = expand('~/.config/nvim/settings.json')


let g:LanguageClient_serverCommands = {
      \ 'c':    ['cquery', '--log-file=/tmp/cq.log ', '--init={"cacheDirectory": "'.$HOME.'/.cache/cquery"}'],
      \ 'cpp': ['cquery', '--log-file=/tmp/cq.log ', '--init={"cacheDirectory": "'.$HOME.'/.cache/cquery"}'],
      \ 'css': ['css-languageserver'],
      \ 'go': ['go-langserver', '-mode', 'stdio'],
      \ 'javascript ': ['javascript-typescript-stdio'],
      \ 'less': ['css-languageserver'],
      \ 'python': ['python3', '-m', 'pyls'],
      \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
      \ 'scss': ['css-languageserver'],
      \ 'sh': ['bash-language-server'],
      \ 'typescript': ['typescript-language-server'],
      \ 'cs': ['/opt/omnisharp-roslyn/OmniSharp.exe', '--languageserver', '--verbose'],
      \ }
