vim.cmd([[
augroup filetypedetect
  autocmd BufNewFile,BufRead *.cr                     setfiletype crystal
  autocmd BufNewFile,BufRead *.feature,*.story        setfiletype cucumber
  autocmd BufNewFile,BufRead *.j2                     setfiletype jinja
  autocmd BufNewFile,BufRead *.js.map                 setfiletype json
  autocmd BufNewFile,BufRead *.postman_collection     setfiletype json
  autocmd BufNewFile,BufRead *.{feature,story}        setfiletype cucumber
  autocmd BufNewFile,BufRead */.kube/config           setfiletype yaml
  autocmd BufNewFile,BufRead */inventory/*.ini        setfiletype ansible_hosts
  autocmd BufNewFile,BufRead */playbooks/*.{yml,yaml} setfiletype yaml.ansible
  autocmd BufNewFile,BufRead */playbooks/*/*.yml      setfiletype ansible
  autocmd BufNewFile,BufRead */templates/*.{yaml,tpl} setfiletype yaml.gotexttmpl
  autocmd BufNewFile,BufRead .babelrc                 setfiletype json
  autocmd BufNewFile,BufRead .buckconfig              setfiletype toml
  autocmd BufNewFile,BufRead .eslintrc                setfiletype json
  autocmd BufNewFile,BufRead .flowconfig              setfiletype ini
  autocmd BufNewFile,BufRead .jsbeautifyrc            setfiletype json
  autocmd BufNewFile,BufRead .jscsrc                  setfiletype json
  autocmd BufNewFile,BufRead .mk                      setfiletype make
  autocmd BufNewFile,BufRead .tern-project            setfiletype json
  autocmd BufNewFile,BufRead .tern-{project,port}     setfiletype json
  autocmd BufNewFile,BufRead .watchmanconfig          setfiletype json
  autocmd BufNewFile,BufRead Dockerfile*              setfiletype dockerfile
  autocmd BufNewFile,BufRead Jenkinsfile              setfiletype groovy
  autocmd BufNewFile,BufRead Tmuxfile,tmux/config     setfiletype tmux
  autocmd BufNewFile,BufRead poetry.lock              setfiletype toml
  autocmd BufNewFile,BufRead yarn.lock                setfiletype yaml
augroup END
]])
