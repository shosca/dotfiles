if [ -x "$(command -v keychain)" ]; then
  keychain $(find ~/.ssh -iname 'id_*' ! -name '*.pub')
  [[ -f ${HOME}/.keychain/$HOST-sh ]] && source ${HOME}/.keychain/$HOST-sh
  [[ -f ${HOME}/.keychain/$HOST-sh-gpg ]] && source ${HOME}/.keychain/$HOST-sh-gpg
fi

# Extend $PATH without duplicates
_extend_path() {
  if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$1" ) ; then
    export PATH="$1:$PATH"
  fi
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  # handle mac stupidity
  if [ -f /usr/libexec/path_helper ]; then
    export PATH=""
    source /etc/profile
    _extend_path "/usr/local/sbin"
  fi
  for _p in $(/usr/bin/find -f /usr/local/Cellar | /usr/bin/grep 'gnubin$' | sort); do
    _extend_path "${_p}"
  done
  export PKG_CONFIG_PATH=""
  for _p in /usr/local/Cellar/*/*/lib/pkgconfig; do
    export PKG_CONFIG_PATH="$_p:${PKG_CONFIG_PATH}"
  done

  if [ -d "/usr/local/opt/openssl@1.1/lib" ]; then
    export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
    export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
    export DYLD_LIBRARY_PATH="/usr/local/opt/openssl/lib:${DYLD_LIBRARY_PATH}"
  fi
  export XDG_RUNTIME_DIR="${TMPDIR}"
else
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
fi

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export MOZ_ENABLE_WAYLAND=1
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

export GEM_HOME="${XDG_DATA_HOME}/gem"
export GEM_SPEC_CACHE="${XDG_CACHE_HOME}/gem"

export PSQLRC="$XDG_CONFIG_HOME/pg/psqlrc"
export PSQL_HISTORY="$XDG_CACHE_HOME/pg/psql_history"
export PGPASSFILE="$XDG_CONFIG_HOME/pg/pgpass"
export PGSERVICEFILE="$XDG_CONFIG_HOME/pg/pg_service.conf"

export ATOM_HOME="${XDG_DATA_HOME}/atom"

export AWS_SHARED_CREDENTIALS_FILE="${HOME}/.ssh/aws/credentials"
export AWS_CONFIG_FILE="${HOME}/.ssh/aws/config"

export CCACHE_CONFIGPATH="${XDG_CONFIG_HOME}/ccache.config"
export CCACHE_DIR="${XDG_CACHE_HOME}/ccache"

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

export MAKEFLAGS="-j$(nproc)"

export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
export ANSIBLE_NOCOWS=1
export PYLINTHOME="${XDG_CACHE_HOME}/pylint"
export PYENV_ROOT="${XDG_CONFIG_HOME}/pyenv"
export PYTHONUSERBASE=${XDG_LOCAL}/python
export PYTHONPATH=$PYTHONPATH:$PYTHONUSERBASE
export IPYTHONDIR="${XDG_CONFIG_HOME}/jupyter"
export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}/jupyter"
export PYTHON_EGG_CACHE="${XDG_CACHE_HOME}/python-eggs"
export WORKON_HOME="${XDG_LOCAL}/share/virtualenvs"
export PIP_VIRUTALENV_BASE="${XDG_LOCAL}/share/virtualenvs"
export MYPY_CACHE_DIR="${XDG_CACHE_HOME}/mypy"

export CARGO_HOME="${XDG_LOCAL}/cargo"
export RUSTUP_HOME="${XDG_LOCAL}/rustup"

export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"

export _JAVA_AWT_WM_NONREPARENTING=1
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
export JAVA_FONTS=/usr/share/fonts/TTF

export EDITOR=vim
export WHICHVIM=vim
if [ -x "$(command -v nvim)" ]; then
  export EDITOR=nvim
  export WHICHVIM=nvim
  alias vim=nvim
fi

export WHICHRG=grep
if [ -x "$(command -v rg)" ]; then
  export WHICHRG=rg
elif [ -x "$(command -v ag)" ]; then
  export WHICHRG=ag
elif [ -x "$(command -v ack)" ]; then
  export WHICHRG=ack
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

[[ -d "$HOME/bin" ]] && _extend_path "$HOME/bin"
[[ -d "GOPATH/bin" ]] && _extend_path "$GOPATH/bin"
[[ -d "$DOTFILES/bin" ]] && _extend_path "$DOTFILES/bin"
[[ -d "$XDG_LOCAL/python/bin" ]] && _extend_path "$XDG_LOCAL/python/bin"
[[ -d "$XDG_DATA_HOME/gem/bin" ]] && _extend_path "$XDG_DATA_HOME/gem/bin"
[[ -d "$CARGO_HOME/bin" ]] && _extend_path "$CARGO_HOME/bin"

[[ -d "/usr/lib/ccache/bin" ]] && _extend_path "/usr/lib/ccache/bin:${PATH}"
[[ -d "/usr/lib/distcc/bin" ]] && _extend_path "/usr/lib/distcc/bin:${PATH}"

[[ -x "$(command -v yarn)" ]] && _extend_path "$(yarn global dir)/node_modules/.bin"
