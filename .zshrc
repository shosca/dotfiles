# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="gentoo2"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to disable command auto-correction.
# DISABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(
    archlinux
    autojump
    django
    git
    git-flow
    go
    golang
    history-substring-search
    mercurial
    ruby
    rbenv
    pip
    python
    systemd
    virtualenv
 )

source $ZSH/oh-my-zsh.sh

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
if [[ -d "/usr/lib/distcc/bin" ]]; then
  PATH="/usr/lib/distcc/bin:${PATH}"
  DISTCC_HOSTS="@buttercup.local/4"
fi

if [[ -d "$HOME/go/bin" ]]; then
  export GOPATH=$HOME/go
  PATH="${HOME}/go/bin:${PATH}"
fi

if [[ -d "$HOME/node/bin" ]]; then
  export NODE_PATH=$HOME/node
  PATH="${HOME}/node/bin:${PATH}"
fi

if [[ -d "/usr/lib/smlnj/bin" ]]; then
  PATH="/usr/lib/smlnj/bin:${PATH}"
fi

if [[ -f /usr/bin/virtualenvwrapper.sh ]]; then
    export WORKON_HOME=~/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source /usr/bin/virtualenvwrapper.sh
fi

if [[ -f /usr/bin/keychain ]]; then
    /usr/bin/keychain ~/.ssh/id_rsa
    source ~/.keychain/$HOST-sh
    source ~/.keychain/$HOST-sh-gpg
fi

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

if [[ -d "$HOME/.rbenv/bin" ]]; then
    PATH=$PATH:$HOME/.rbenv/bin
    eval "$(rbenv init -)"
fi

export WORKON_HOME="$HOME/.virtualenvs"
export EDITOR=vim
export MAKEFLAGS="-j$(grep processor /proc/cpuinfo | wc -l)"

alias pygrep="grep --include='*.py' $*"
alias rbgrep="grep --include='*.rb' $*"
alias csgrep="grep --include='*.cs' $*"

alias dmesg="dmesg -L"
# some more ls aliases
alias ll='ls -lh'
alias la='ls -A'
alias ldir='ls -lhA |grep ^d'
alias lfiles='ls -lhA |grep ^-'
alias l='ls -CF'

# To check a process is running in a box with a heavy load: pss
alias pss='ps -ef | grep $1'

# usefull alias to browse your filesystem for heavy usage quickly
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
alias ondemand='sudo cpupower frequency-set -g ondemand'
alias powersave='sudo cpupower frequency-set -g powersave'
alias performance='sudo cpupower frequency-set -g performance'
alias notify='notify-send -i gnome-terminal "[$?] $(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/;\s*alert$//'\'')"'

alias tma='tmux attach -d -t'

cleanvim() {
    echo "Cleaning ~/.vimbackup/"
    rm -Rf ~/.vimbackup/*
    echo "Cleaning ~/.vimswap/"
    rm -Rf ~/.vimswap/*
    echo "Cleaning ~/.vimviews/"
    rm -Rf ~/.vimviews/*
    echo "Cleaning ~/.vimundo/"
    rm -Rf ~/.vimundo/*
    echo "All done!"
}

unset GREP_OPTIONS
alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn'
