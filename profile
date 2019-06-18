# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export DOTFILES="${HOME}/dotfiles"
export GOPATH="${HOME}/go"

export ZSH_AUTOSUGGEST_STRATEGY=(history)
export AUTOSWITCH_VIRTUAL_ENV_DIR=$XDG_DATA_HOME/virtualenvs
export AUTOSWITCH_DEFAULT_REQUIREMENTS="$DOTFILES/autoswitch_requires.txt"

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

export MAKEFLAGS="-j$(grep processor /proc/cpuinfo | wc -l)"

export PYTHONUSERBASE=${HOME}/.local
export PYTHONPATH=$PYTHONPATH:$PYTHONUSERBASE

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

# Extend $NODE_PATH
if [ -d ~/.npm-global ]; then
  export NODE_PATH="$NODE_PATH:$HOME/.npm-global/lib/node_modules"
fi

# Extend $PATH without duplicates
_extend_path() {
  if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$1" ) ; then
    export PATH="$1:$PATH"
  fi
}

[[ -d "$HOME/bin" ]] && _extend_path "$HOME/bin"
[[ -d "$HOME/dc" ]] && _extend_path "$HOME/dc"
[[ -d "$HOME/go/bin" ]] && _extend_path "$HOME/go/bin"
[[ -d "$DOTFILES/bin" ]] && _extend_path "$DOTFILES/bin"
[[ -d "$HOME/.npm-global" ]] && _extend_path "$HOME/.npm-global/bin"
[[ -d "$HOME/.rvm/bin" ]] && _extend_path "$HOME/.rvm/bin"
[[ -d "$HOME/.cargo/bin" ]] && _extend_path "$HOME/.cargo/bin"
[[ -d "$HOME/.local/bin" ]] && _extend_path "$HOME/.local/bin"

[[ -d "/usr/lib/ccache/bin" ]] && _extend_path "/usr/lib/ccache/bin:${PATH}"
[[ -d "/usr/lib/distcc/bin" ]] && _extend_path "/usr/lib/distcc/bin:${PATH}"

if type yarn >/dev/null 2>&1; then
  _extend_path "$(yarn global dir)/node_modules/.bin"
fi
