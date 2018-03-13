XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_CONFIG_HOME="${XDG_CACHE_HOME:-$HOME/.config}"

export ZSH=$XDG_CACHE_HOME/oh-my-zsh

if [ ! -e ${ZSH} ]; then \
	git clone https://github.com/robbyrussell/oh-my-zsh.git ${ZSH} ; \
fi

ZSH_CUSTOM=${HOME}/dotfiles/zsh

plugins=(
	archlinux
	command-not-found
	django
	docker
	docker-compose
	fzf
	git
	git-flow
	github
	go
	golang
	history-substring-search
	pip
	postgres
	python
	rust
	systemd
	virtualenv
)
ZSH_THEME='gentoo2'

source $ZSH/oh-my-zsh.sh

# dotenv
dotenv () {
  if [[ -r $PWD/.env ]]; then
    set -a
    source $PWD/.env
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd dotenv

# User configuration

setopt appendhistory
setopt extendedhistory
setopt incappendhistory
setopt histfindnodups
setopt sharehistory

bindkey '^[[A' fzf-history-widget
bindkey '\C-P' history-substring-search-up
bindkey '\C-N' history-substring-search-down

autoload -U compinit
compinit

[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh

alias resrc='source ~/.zshrc'

set -a
. $HOME/dotfiles/aliases
[[ -f $HOME/.zshrc.local ]] && . $HOME/.zshrc.local
