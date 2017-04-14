" Filetype Detection {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

augroup filetypedetect "{

    autocmd BufNewFile,BufReadPost *.feature,*.story setf cucumber

    autocmd BufNewFile,BufRead */inventory/*         setf ansible
    autocmd BufNewFile,BufRead */playbooks/*/*.yml   setf ansible

    autocmd BufNewFile,BufRead .tern-project         setf json

    autocmd BufNewFile,BufRead Tmuxfile,tmux/config  setf tmux

    autocmd BufRead,BufNewFile Vagrantfile           setf ruby

    autocmd BufRead,BufNewFile *.pp                  setf puppet

    autocmd BufRead,BufNewFile *.groovy              setf groovy

augroup END " }
