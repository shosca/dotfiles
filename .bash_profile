# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth
export HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if [[ -f $HOME/dotfiles/git-prompt.sh ]]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \n\$ '
else
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(__git_ps1 " (%s)") \n\$ '
fi

PROMPT_COMMAND='history -a; history -n'

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

export HISTIGNORE="&:ls:[bf]g:exit:cd:ls"

shopt -s cmdhist
shopt -s histappend

alias resrc='source ~/.bashrc'

export EDITOR="vim"

PATH="${HOME}/bin:${PATH}"

if [[ -d "$HOME/bin" ]]; then
  PATH="${HOME}/bin:${PATH}"
fi

if [[ -d "$HOME/src/bin" ]]; then
  PATH="${HOME}/src/bin:${PATH}"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

if [[ -d "/usr/lib/ccache/bin" ]]; then
  PATH="/usr/lib/ccache/bin:${PATH}"
fi

if [[ -d "$HOME/.local/share/bash-completion" ]]; then
  for f in $HOME/.local/share/bash-completion/* ; do
    source $f
  done
fi

if [[ -d "$HOME/go/bin" ]]; then
  export GOPATH=$HOME/go
  PATH="${HOME}/go/bin:${PATH}"
fi

if [[ -d "$HOME/node/bin" ]]; then
  export NODE_PATH=$HOME/node
  PATH="${HOME}/node/bin:${PATH}"
fi

[[ -s "/usr/bin/virtualenvwrapper.sh" ]] && source "/usr/bin/virtualenvwrapper_lazy.sh"

BASE16_SHELL="$HOME/dotfiles/base16-turkishcoffee.dark.sh"
[[ -f $BASE16_SHELL  ]] && source $BASE16_SHELL

[[ -f $HOME/dotfiles/.aliases ]] && source $HOME/dotfiles/.aliases
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

