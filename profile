case "${TERM}" in
	xterm*)
		export TERM=xterm-256color
		cache_term_colors=256
		if [[ -f "/usr/bin/dircolors" ]]; then
			eval "$(dircolors -b)"
		fi
		;;
	screen)
		cache_term_colors=256
		if [[ -f "/usr/bin/dircolors" ]]; then
			eval "$(dircolors -b)"
		fi
		;;
	dumb)
		cache_term_colors=2
		;;
	*)
		cache_term_colors=16
		if [[ -f "/usr/bin/dircolors" ]]; then
			eval "$(dircolors -b)"
		fi
		;;
esac

if [[ -f "/usr/bin/dircolors" ]] && [[ -f ${HOME}/.dircolors ]] && [[ ${cache_term_colors} -ge 8 ]]; then
  eval $(dircolors -b ${HOME}/.dircolors)
fi

mkdir -p ${HOME}/bin
export PATH="${HOME}/bin:${PATH}"

mkdir -p ${HOME}/src/bin
export PATH="${HOME}/src/bin:${PATH}"

if [[ -d "/usr/lib/ccache/bin" ]]; then
  export PATH="/usr/lib/ccache/bin:${PATH}"
fi
if [[ -d "/usr/lib/distcc/bin" ]]; then
  export PATH="/usr/lib/distcc/bin:${PATH}"
  DISTCC_HOSTS="@buttercup.local/4"
fi

mkdir -p ${HOME}/go/bin
export PATH="${HOME}/go/bin:${PATH}"

mkdir -p ${HOME}/node/bin
export PATH="${HOME}/node/bin:${PATH}"

mkdir -p ${HOME}/.cargo/bin
export PATH="${HOME}/.cargo/bin:${PATH}"

if type keychain >/dev/null 2>&1; then
  keychain ${HOME}/.ssh/id_*.key
  [[ -f ${HOME}/.keychain/$HOST-sh ]] && source ${HOME}/.keychain/$HOST-sh
  [[ -f ${HOME}/.keychain/$HOST-sh-gpg ]] && source ${HOME}/.keychain/$HOST-sh-gpg
fi

if type yarn >/dev/null 2>&1; then
  export PATH="$(yarn global dir)/node_modules/.bin:${PATH}"
fi

export MAKEFLAGS="-j$(grep processor /proc/cpuinfo | wc -l)"
unset GREP_OPTIONS

export EDITOR=vim
if type nvim >/dev/null; then
  export EDITOR=nvim
  alias vim=nvim
fi

export PYTHONUSERBASE=${HOME}/.local
export PYTHONPATH=$PYTHONPATH:$PYTHONUSERBASE
export PATH="$PYTHONUSERBASE/bin:$PATH"

mkdir -p ${HOME}/dc
export PATH="${HOME}/dc:${PATH}"

