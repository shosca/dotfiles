# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="gentoo"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(history history-substring-search archlinux git golang mercurial ruby rbenv rails django pip python ssh-agent virtualenv systemd)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

setopt inc_append_history
setopt share_history

autoload -U compinit
compinit

case "${TERM}" in
  xterm*)
    export TERM=xterm-256color
    cache_term_colors=256
    if [[ -f "/usr/bin/dircolors" ]] ; then
      eval "`dircolors -b`"
    fi
    alias ls='ls --color=auto'
    ;;
  screen)
    cache_term_colors=256
    if [[ -f "/usr/bin/dircolors" ]] ; then
      eval "`dircolors -b`"
    fi
    alias ls='ls --color=auto'
    ;;
  dumb)
    cache_term_colors=2
    ;;
  *)
    cache_term_colors=16
    if [[ -f "/usr/bin/dircolors" ]] ; then
      eval "`dircolors -b`"
    fi
    alias ls='ls --color=auto'
    ;;
esac

if [[ -f "/usr/bin/dircolors" ]] && [[ -f ${HOME}/.dircolors ]] && [[ ${cache_term_colors} -ge 8 ]] ; then
  eval $(dircolors -b ${HOME}/.dircolors)
fi


PATH="${HOME}/bin:${PATH}"

if [[ -d "$HOME/bin" ]]; then
  PATH="${HOME}/bin:${PATH}"
fi

if [[ -d "$HOME/src/bin" ]]; then
  PATH="${HOME}/src/bin:${PATH}"
fi

if [[ -d "/usr/lib/ccache/bin" ]]; then
  PATH="/usr/lib/ccache/bin:${PATH}"
fi

if [[ -d "$HOME/go/bin" ]]; then
  export GOPATH=$HOME/go
  PATH="${HOME}/go/bin:${PATH}"
fi

if [[ -d "$HOME/node/bin" ]]; then
  export NODE_PATH=$HOME/node
  PATH="${HOME}/node/bin:${PATH}"
fi

if [[ -f /usr/bin/virtualenvwrapper.sh ]]; then
    export WORKON_HOME=~/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source /usr/bin/virtualenvwrapper.sh
fi

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

if [[ -d "$HOME/.rbenv/bin" ]]; then
    PATH=$PATH:$HOME/.rbenv/bin
    eval "$(rbenv init -)"
fi

export WORKON_HOME="$HOME/.virtualenvs"
export EDITOR=vim
export PAGER=vimpager

alias less=$PAGER
alias zless=$PAGER
alias pygrep="grep --include='*.py' $*"
alias rbgrep="grep --include='*.rb' $*"
alias csgrep="grep --include='*.cs' $*"
alias brgrep="grep --include='*.brail' $*"

# some more ls aliases
alias ll='ls -lhX'
alias la='ls -A'
alias ldir='ls -lhA |grep ^d'
alias lfiles='ls -lhA |grep ^-'
alias l='ls -CF'

# To check a process is running in a box with a heavy load: pss
alias pss='ps -ef | grep $1'

# usefull alias to browse your filesystem for heavy usage quickly
#alias ducks='ls -A | grep -v -e '\''^\.\.$'\'' |xargs -i du -ks {} |sort -rn |head -16 | awk '\''{print $2}'\'' | xargs -i du -hs {}'
#lias ducks='for f in ./* ./.*; do du -ks "${f}"; done | sort -rn | head -16'
alias ducks='sudo du -sk * | sort -n | perl -ne '\''($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}'\'

alias c='clear'
alias up='cd ..'

alias radeondynpm='echo dynpm | sudo tee -a /sys/class/drm/card0/device/power_method'
alias radeonprofile='echo profile | sudo tee -a /sys/class/drm/card0/device/power_method'
alias radeonlow='echo low | sudo tee -a /sys/class/drm/card0/device/power_profile'
alias radeonmid='echo mid| sudo tee -a /sys/class/drm/card0/device/power_profile'
alias radeondefault='echo default | sudo tee -a /sys/class/drm/card0/device/power_profile'
alias radeonhigh='echo high | sudo tee -a /sys/class/drm/card0/device/power_profile'
alias drmdebug='echo 14 | sudo tee -a /sys/module/drm/parameters/debug'
alias drmnodebug='echo 0 | sudo tee -a /sys/module/drm/parameters/debug'
alias resrc='source ~/.zshrc'
alias rsyncf='rsync -v --recursive --links --times -D --delete'
alias rsyncd='rsync -v --recursive --links --times -D'
alias pushtobuttercup='rsync -v --recursive --links --times -D --delete ~/src/ buttercup.local:~/src/'
alias pullfrombuttercup='rsync -v --recursive --links --times -D --delete buttercup.local:~/src/ ~/src/'
alias ondemand='sudo cpupower frequency-set -g ondemand'
alias powersave='sudo cpupower frequency-set -g powersave'
alias notify='notify-send -i gnome-terminal "[$?] $(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/;\s*alert$//'\'')"'

