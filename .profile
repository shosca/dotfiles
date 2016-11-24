
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

mkdir -p ${HOME}/bin
PATH="${HOME}/bin:${PATH}"

mkdir -p ${HOME}/src/bin
PATH="${HOME}/src/bin:${PATH}"

if [[ -d "/usr/lib/ccache/bin" ]]; then
  PATH="/usr/lib/ccache/bin:${PATH}"
fi
if [[ -d "/usr/lib/distcc/bin" ]]; then
  PATH="/usr/lib/distcc/bin:${PATH}"
  DISTCC_HOSTS="@buttercup.local/4"
fi

mkdir -p ${HOME}/go/bin
PATH="${HOME}/go/bin:${PATH}"

mkdir -p ${HOME}/node/bin
PATH="${HOME}/node/bin:${PATH}"

if type virtualenvwrapper.sh > /dev/null ; then
  export WORKON_HOME=~/.virtualenvs
  export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
  source /usr/bin/virtualenvwrapper.sh
fi

if type keychain > /dev/null ; then
  keychain ~/.ssh/id_*.key
  [[ -f ~/.keychain/$HOST-sh ]] && source ~/.keychain/$HOST-sh
  [[ -f ~/.keychain/$HOST-sh-gpg ]] && source ~/.keychain/$HOST-sh-gpg
fi

export MAKEFLAGS="-j$(grep processor /proc/cpuinfo | wc -l)"
unset GREP_OPTIONS

export EDITOR=vim
if type nvim > /dev/null ; then
    export EDITOR=nvim
    alias vim=nvim
fi

export PYTHONUSERBASE=~/.config/python
export PYTHONPATH=$PYTHONPATH:$PYTHONUSERBASE

BASE16_SHELL="$HOME/dotfiles/base16-turkishcoffee.dark.sh"
[[ -f $BASE16_SHELL  ]] && source $BASE16_SHELL

[[ -f $HOME/dotfiles/.aliases ]] && source $HOME/dotfiles/.aliases
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

