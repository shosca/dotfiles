# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_LOCAL="${XDG_LOCAL:-$HOME/.local}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DOTFILES="${HOME}/dotfiles"

if [[ "$OSTYPE" == "darwin"* ]]; then
  export XDG_RUNTIME_DIR="${HOME}/run"
fi

# Extend $PATH without duplicates
function _extend_path {
  case ":$PATH:" in
  *":$1:"*) : ;;        # already there
  *) PATH="$1:$PATH" ;; # or PATH="$PATH:$1"
  esac
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  alias nproc="sysctl -n hw.logicalcpu"
  # handle mac stupidity
  if [ -f /usr/libexec/path_helper ]; then
    export PATH=""
    source /etc/profile
    export PATH="/usr/local/sbin:${PATH}"
  fi
  for _p in $(/usr/bin/find -f /usr/local/Cellar | /usr/bin/grep 'gnubin$' | sort); do
    _extend_path $_p
  done
  export PKG_CONFIG_PATH=""
  for _p in /usr/local/Cellar/*/*/lib/pkgconfig; do
    export PKG_CONFIG_PATH="$_p:${PKG_CONFIG_PATH}"
  done

  export XDG_RUNTIME_DIR="${TMPDIR}"
fi

export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

#export RADV_PERFTEST=
#export MANGOHUD=1
#export MANGOHUD_DLSYM=1

export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export MOZ_ENABLE_WAYLAND=1
export MOZ_USE_XINPUT2=1

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

#export SDL_VIDEO_DRIVER=wayland
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

export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"

export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"

export _JAVA_AWT_WM_NONREPARENTING=1
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
export JAVA_FONTS=/usr/share/fonts/TTF

export EDITOR=nvim

[[ -d "$HOME/bin" ]] && _extend_path "$HOME/bin"
[[ -d "$XDG_LOCAL/bin" ]] && _extend_path "$XDG_LOCAL/bin"
[[ -d "$GOPATH/bin" ]] && _extend_path "$GOPATH/bin"
[[ -d "$XDG_DATA_HOME/gem/bin" ]] && _extend_path "$XDG_DATA_HOME/gem/bin"
[[ -d "$XDG_DATA_HOME/npm/bin" ]] && _extend_path "$XDG_DATA_HOME/npm/bin"
[[ -d "$CARGO_HOME/bin" ]] && _extend_path "$CARGO_HOME/bin"
[[ -d "/usr/lib/ccache/bin" ]] && _extend_path "/usr/lib/ccache/bin"
[[ -d "/usr/lib/distcc/bin" ]] && _extend_path "/usr/lib/distcc/bin"
[[ -d "$PYENV_ROOT/bin" ]] && _extend_path "$PYENV_ROOT/bin"
[[ -x "$(command -v pyenv)" ]] && eval "$(pyenv init --path)"
