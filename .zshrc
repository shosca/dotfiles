# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="gentoo2"
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
ZSH_CUSTOM=$HOME/dotfiles

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
    pip
    python
    rbenv
    rvm
    ruby
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
    ;;
  screen)
    cache_term_colors=256
    if [[ -f "/usr/bin/dircolors" ]] ; then
      eval "`dircolors -b`"
    fi
    ;;
  dumb)
    cache_term_colors=2
    ;;
  *)
    cache_term_colors=16
    if [[ -f "/usr/bin/dircolors" ]] ; then
      eval "`dircolors -b`"
    fi
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

export GOPATH=$HOME/go
if [[ -d "$HOME/go/bin" ]]; then
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

if [[ -f /usr/bin/keychain ]]; then
    /usr/bin/keychain ~/.ssh/id_*
    [[ -f ~/.keychain/$HOST-sh ]] && source ~/.keychain/$HOST-sh
    [[ -f ~/.keychain/$HOST-sh-gpg ]] && source ~/.keychain/$HOST-sh-gpg
fi

export WORKON_HOME="$HOME/.virtualenvs"
export MAKEFLAGS="-j$(grep processor /proc/cpuinfo | wc -l)"
unset GREP_OPTIONS

export EDITOR=vim
if [[ -f /usr/bin/nvim ]]; then
    export EDITOR=nvim
    alias vim=nvim
fi

BASE16_SHELL="$HOME/dotfiles/base16-turkishcoffee.dark.sh"
[[ -f $BASE16_SHELL  ]] && source $BASE16_SHELL

[[ -f $HOME/dotfiles/.aliases ]] && source $HOME/dotfiles/.aliases
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

