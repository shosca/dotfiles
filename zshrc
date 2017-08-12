XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

source $HOME/dotfiles/zsh/antigen.zsh

antigen use oh-my-zsh

antigen bundle archlinux
#antigen bundle autojump
#antigen bundle aws
#antigen bundle cargo
#antigen bundle celery
antigen bundle command-not-found
#antigen bundle django
#antigen bundle docker
#antigen bundle docker-compose
#antigen bundle dotenv
#antigen bundle fabric
antigen bundle git
#antigen bundle git-extras
#antigen bundle git-flow
#antigen bundle github
#antigen bundle go
#antigen bundle golang
#antigen bundle gpg-agent
antigen bundle history-substring-search
#antigen bundle hub
#antigen bundle mercurial
#antigen bundle pip
#antigen bundle postgres
#antigen bundle python
#antigen bundle rbenv
#antigen bundle ruby
#antigen bundle rust
#antigen bundle rvm
#antigen bundle systemd
#antigen bundle virtualenv
#antigen bundle yarn

antigen bundle $HOME/dotfiles/zsh dotenv
antigen theme $HOME/dotfiles/zsh gentoo2

antigen apply

# User configuration

setopt appendhistory
setopt extendedhistory
setopt incappendhistory
setopt histfindnodups
setopt sharehistory

bindkey '\C-P' history-substring-search-up
bindkey '\C-N' history-substring-search-down

autoload -U compinit
compinit

source ~/.profile
