# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

export DOTFILES="${HOME}/dotfiles"

if [ ! -e ${XDG_CACHE_HOME}/zplug ]; then
  git clone https://github.com/zplug/zplug.git ${XDG_CACHE_HOME}/zplug
fi

# Source zplug manager (https://github.com/zplug/zplug)
source ${XDG_CACHE_HOME}/zplug/init.zsh

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Do not override files using `>`, but it's still possible using `>!`
set -o noclobber

# Extend $PATH without duplicates
_extend_path() {
  if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$1" ) ; then
    export PATH="$1:$PATH"
  fi
}

# Default pager
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

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

# Let zplug manage itself like other packages
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Oh-My-Zsh core
#zplug "lib/*", from:oh-my-zsh
zplug "lib/bzr", from:oh-my-zsh
zplug "lib/clipboard", from:oh-my-zsh
zplug "lib/compfix", from:oh-my-zsh
zplug "lib/completion", from:oh-my-zsh
zplug "lib/correction", from:oh-my-zsh
zplug "lib/diagnostics", from:oh-my-zsh
zplug "lib/directories", from:oh-my-zsh
zplug "lib/functions", from:oh-my-zsh
zplug "lib/git", from:oh-my-zsh
zplug "lib/grep", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/nvm", from:oh-my-zsh
zplug "lib/prompt_info_functions", from:oh-my-zsh
zplug "lib/spectrum", from:oh-my-zsh
zplug "lib/termsupport", from:oh-my-zsh
zplug "lib/theme-and-appearance", from:oh-my-zsh

# Oh-My-Zsh plugins
zplug "plugins/archlinux", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/django", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/extract", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/github", from:oh-my-zsh
zplug "plugins/go", from:oh-my-zsh
zplug "plugins/golang", from:oh-my-zsh
zplug "plugins/history-substring-search", from:oh-my-zsh
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/nvm", from:oh-my-zsh
zplug "plugins/postgres", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh
zplug "plugins/rust", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/systemd", from:oh-my-zsh
zplug "plugins/virtualenv", from:oh-my-zsh
zplug "plugins/yarn", from:oh-my-zsh

# Zsh improvements
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "hlissner/zsh-autopair", defer:2

# Extra
zplug "lukechilds/zsh-better-npm-completion", defer:2
zplug "denysdovhan/gitio-zsh", as:command, use:"gitio.zsh", rename-to:"gitio"
zplug "rauchg/wifi-password", as:command, use:"wifi-password.sh", rename-to:"wifi-password"

# Spaceship ZSH
if [[ -d "$HOME/Projects/Repos/spaceship-prompt" ]]; then
  zplug "$HOME/Projects/Repos/spaceship-prompt", from:local, as:theme, use:"spaceship.zsh"
else
  zplug "denysdovhan/spaceship-prompt", as:theme, use:"spaceship.zsh"
fi

# Dotfiles
zplug "$DOTFILES/zsh/lib/misc", from:local, if:"[[ -f $DOTFILES/zsh/lib ]]"

# Custom local overridings
zplug "~/.zsh.local", from:local, if:"[[ -f ~/.zsh.local ]]"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  zplug install
fi

# Then, source plugins and add commands to $PATH
zplug load

set -a
. $HOME/dotfiles/commonsh
. $HOME/dotfiles/aliases

bindkey '^[[A' fzf-history-widget
bindkey '\C-P' history-substring-search-up
bindkey '\C-N' history-substring-search-down
