# handle mac stupidity
if [ -f /usr/libexec/path_helper ]; then
  export PATH=""
  source /etc/profile
fi
# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

export DOTFILES="${HOME}/dotfiles"

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_LOCAL="${XDG_LOCAL:-$HOME/.local}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export GOPATH="${XDG_DATA_HOME}/go"

export ZSH_AUTOSUGGEST_STRATEGY=(history)
export PEW_DEFAULT_REQUIREMENTS="$DOTFILES/autoswitch_requires.txt"

export DISABLE_MAGIC_FUNCTIONS=true

export PAGER='less'

# less options
less_opts=(
  # Quit if entire file fits on first screen.
  --quit-if-one-screen
  # Ignore case in searches that do not contain uppercase.
  --ignore-case
  # Allow ANSI colour escapes, but no other escapes.
  --RAW-CONTROL-CHARS
  # Quiet the terminal bell. (when trying to scroll past the end of the buffer)
  --quiet
  # Do not complain when we are on a dumb terminal.
  --dumb
)
export LESS="${less_opts[*]}"

[[ -d /proc ]] && export MAKEFLAGS="-j$(grep processor /proc/cpuinfo | wc -l)"

export PYTHONUSERBASE=${XDG_LOCAL}
export PYTHONPATH=$PYTHONPATH:$PYTHONUSERBASE

export CARGO_HOME=${XDG_CONFIG_HOME}/cargo

export NPM_CONFIG_USERCONFIG=${XDG_CONFIG_HOME}/npm/npmrc

export EDITOR=vim
if type nvim >/dev/null; then
  export EDITOR=nvim
  alias vim=nvim
fi

unset GREP_OPTIONS

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

# Extend $PATH without duplicates
_extend_path() {
  if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$1" ) ; then
    echo "adding $1 to PATH"
    export PATH="$1:$PATH"
  fi
}

[[ -d "$HOME/bin" ]] && _extend_path "$HOME/bin"
[[ -d "GOPATH/bin" ]] && _extend_path "$GOPATH/bin"
[[ -d "$DOTFILES/bin" ]] && _extend_path "$DOTFILES/bin"
[[ -d "$XDG_LOCAL/bin" ]] && _extend_path "$XDG_LOCAL/bin"
[[ -d "$XDG_DATA_HOME/npm/bin" ]] && _extend_path "$XDG_DATA_HOME/npm/bin"

[[ -d "/usr/lib/ccache/bin" ]] && _extend_path "/usr/lib/ccache/bin:${PATH}"
[[ -d "/usr/lib/distcc/bin" ]] && _extend_path "/usr/lib/distcc/bin:${PATH}"

if type yarn >/dev/null 2>&1; then
  _extend_path "$(yarn global dir)/node_modules/.bin"
fi

if [ -x "$(command -v gfind)" ]; then
  for _p in $(gfind /usr/local/Cellar -type d -iname gnubin | sort); do
    _extend_path "${_p}"
  done
fi

if [ -d "${VIRTUAL_ENV}/bin/activate" ]; then
	source ${VIRTUAL_ENV}/bin/activate
fi

if [ -d "/usr/local/opt/openssl@1.1/lib" ]; then
	export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
fi
