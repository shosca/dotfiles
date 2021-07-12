mkdir -p ~/.zfunc

fpath+=~/.zfunc

[ -x "$(command -v pew)" ] && poetry completions zsh > ~/.zfunc/_poetry

if [ ! -e ${XDG_CACHE_HOME}/zplug ]; then
  git clone https://github.com/zplug/zplug.git ${XDG_CACHE_HOME}/zplug
fi

if [ ! -e ~/.bash-my-aws ]; then
  git clone https://github.com/bash-my-aws/bash-my-aws.git ~/.bash-my-aws
fi
export PATH="$PATH:$HOME/.bash-my-aws/bin"
source ~/.bash-my-aws/aliases

# For ZSH users, uncomment the following two lines:
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

source ~/.bash-my-aws/bash_completion.sh


# Source zplug manager (https://github.com/zplug/zplug)
source ${XDG_CACHE_HOME}/zplug/init.zsh

# Do not override files using `>`, but it's still possible using `>!`
# set -o noclobber

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

# Let zplug manage itself like other packages
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Oh-My-Zsh core
zplug "lib/*", from:oh-my-zsh

# Oh-My-Zsh plugins
zplug "plugins/archlinux", from:oh-my-zsh
zplug "plugins/aws", from:oh-my-zsh
zplug "plugins/brew", from:oh-my-zsh
zplug "plugins/cargo", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/django", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/extract", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/github", from:oh-my-zsh
zplug "plugins/golang", from:oh-my-zsh
zplug "plugins/helm", from:oh-my-zsh
zplug "plugins/kubectl", from:oh-my-zsh
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/postgres", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh
zplug "plugins/rust", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/systemd", from:oh-my-zsh
zplug "plugins/terraform", from:oh-my-zsh
zplug "plugins/virtualenv", from:oh-my-zsh
zplug "plugins/yarn", from:oh-my-zsh

# Zsh improvements
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "hlissner/zsh-autopair", defer:2

# Extra
zplug "lukechilds/zsh-better-npm-completion", defer:2
zplug "junegunn/fzf", use:"shell/*.zsh"
zplug "pbar1/zsh-terraform"

if [[ -d "$HOME/src/zsh-pew" ]]; then
  zplug "$HOME/src/zsh-pew", from:local, use:"pew.plugin.zsh"
else
  zplug "shosca/zsh-pew"
fi

# Custom local overridings
zplug "$HOME/.zsh.local", from:local, use:"*", if:"[[ -d ~/.zsh.local ]]"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  zplug install
fi

# Then, source plugins and add commands to $PATH
zplug load
if [ -x "$(command -v starship)" ]; then
  eval "$(starship init zsh)"
fi
if [ -x "$(command -v awless)" ]; then
  source <(awless completion zsh)
fi

bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget
bindkey '^R' fzf-history-widget

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey '^b' backward-word
bindkey '^f' forward-word

if [ -f "${HOME}/.ssh/env" ]; then
	source ${HOME}/.ssh/env
fi

source_sh() {
  emulate -LR sh
  . "$@"
}

alias resrc='source ~/.zshrc'
source_sh ${HOME}/.aliases

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
