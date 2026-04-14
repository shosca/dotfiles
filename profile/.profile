export DO_NOT_TRACK=1
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_LOCAL="${XDG_LOCAL:-$HOME/.local}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DOTFILES="${HOME}/dotfiles"
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

export WAYLANDDRV_PRIMARY_MONITOR=DP-1
export ROCM_HOME=/opt/rocm/
export VKD3D_SHADER_CACHE_PATH=$XDG_CACHE_HOME/vkd3d

export MOZ_ENABLE_WAYLAND=1
export MOZ_USE_XINPUT2=1

export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker

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

export ANTHROPIC_BASE_URL="http://127.0.0.1:8012"
export ANTHROPIC_API_KEY="not-set"
export ANTHROPIC_AUTH_TOKEN="not-set"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export CLAUDE_CODE_ENABLE_TELEMETRY=0
export DISABLE_AUTOUPDATER=1
export DISABLE_TELEMETRY=1
export CLAUDE_CODE_DISABLE_1M_CONTEXT=1
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=32768
