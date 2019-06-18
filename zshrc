if [ ! -e ${XDG_CACHE_HOME}/zplug ]; then
  git clone https://github.com/zplug/zplug.git ${XDG_CACHE_HOME}/zplug
fi

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
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/django", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/extract", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/github", from:oh-my-zsh
zplug "plugins/go", from:oh-my-zsh
zplug "plugins/golang", from:oh-my-zsh
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/nvm", from:oh-my-zsh
zplug "plugins/postgres", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh
zplug "plugins/rust", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/systemd", from:oh-my-zsh
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

zplug "MichaelAquilina/zsh-autoswitch-virtualenv"

zplug "denysdovhan/spaceship-prompt", as:theme, use:"spaceship.zsh"

# Dotfiles
#zplug "$DOTFILES/zsh/lib/misc", from:local, if:"[[ -f $DOTFILES/zsh/lib ]]"

# Custom local overridings
zplug "~/.zsh.local", from:local, if:"[[ -f ~/.zsh.local ]]"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  zplug install
fi

# Then, source plugins and add commands to $PATH
zplug load

set -a
. $HOME/dotfiles/commonsh
. $HOME/dotfiles/aliases

bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget
bindkey '^R' fzf-history-widget

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
