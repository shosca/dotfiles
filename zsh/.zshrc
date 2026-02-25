export DOTFILES="${HOME}/dotfiles"
export DISABLE_MAGIC_FUNCTIONS=true
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"
export REPORTTIME=2
export TIMEFMT="%U user %S system %P cpu %*Es total"

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

[ -x "$(command -v fzf)" ] && source <(fzf --zsh)
[ -x "$(command -v starship)" ] && eval "$(starship init zsh)"

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify
setopt INC_APPEND_HISTORY
unsetopt HIST_BEEP
setopt share_history
setopt EXTENDED_HISTORY
setopt pushd_ignore_dups
setopt AUTO_CD              # If a command is issued that can’t be executed as a normal command,
                            # and the command is the name of a directory, perform the cd command
                            # to that directory.
                            #
setopt ALWAYS_TO_END        # Move cursor to the end of a completed word.
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt AUTO_MENU            # Show completion menu on a successive tab press.
setopt AUTO_PARAM_SLASH     # If completed parameter is a directory, add a trailing slash.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.
unsetopt MENU_COMPLETE      # Do not autoselect the first completion entry.
setopt INTERACTIVE_COMMENTS  # Enable comments in interactive shell.

# Completion styling
fzf_file_or_dir_preview="if [ -d {} ]; then eza -1 -a --color=always {} | head -200; else bat --style=header-filename,grid --color=always --line-range :500 {}; fi"
dir_or_file_preview='if [ -d $realpath ]; then eza -1 -a --color=always $realpath | head -200; else bat --style=header-filename,grid --color=always --line-range :500 $realpath; fi'
dir_preview='eza --color=always -1 -a --icons=always $realpath'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview $dir_preview
zstyle ':fzf-tab:complete:bat:*' fzf-preview $dir_or_file_preview
zstyle ':fzf-tab:complete:cat:*' fzf-preview $dir_or_file_preview
zstyle ':fzf-tab:complete:eza:*' fzf-preview $dir_or_file_preview
zstyle ':fzf-tab:complete:lsd:*' fzf-preview $dir_preview
zstyle ':fzf-tab:complete:nvim:*' fzf-preview $dir_or_file_preview
zstyle ':fzf-tab:complete:less:*' fzf-preview $dir_or_file_preview
zstyle ':fzf-tab:complete:head:*' fzf-preview $dir_or_file_preview
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview $dir_preview

# Speed up autocomplete, force prefix mapping
# zstyle ':completion:*' accept-exact '*(N)'
# zstyle ':completion:*' fzf-search-display true
# zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)*==34=34}:${(s.:.)LS_COLORS}")';

mkdir -p ~/.zfunc
fpath+=~/.zfunc

# Extend $PATH without duplicates
_extend_path() {
  case ":$PATH:" in
  *":$1:"*) : ;;        # already there
  *) PATH="$1:$PATH" ;; # or PATH="$PATH:$1"
  esac
}

source_sh() {
  emulate -LR sh
  . "$@"
  emulate -LR zsh
}

source_sh ${HOME}/.aliases
alias resrc='source ~/.zshrc'

if [ ! -e ~/.bash-my-aws ]; then
  git clone https://github.com/bash-my-aws/bash-my-aws.git ~/.bash-my-aws
fi
export PATH="$PATH:$HOME/.bash-my-aws/bin"
source_sh ~/.bash-my-aws/aliases
source_sh ~/.bash-my-aws/bash_completion.sh

if [ ! -e ${HOME}/.zgenom ]; then
  git clone https://github.com/jandamm/zgenom.git "${HOME}/.zgenom"
fi
source "${HOME}/.zgenom/zgenom.zsh"

fpath+=${DOTFILES}/zfunc

if ! zgenom saved; then
    zgenom ohmyzsh lib/
    # zgenom ohmyzsh plugins/archlinux
    # zgenom ohmyzsh plugins/aws
    # zgenom ohmyzsh plugins/docker
    # zgenom ohmyzsh plugins/git
    # zgenom ohmyzsh plugins/invoke
    # zgenom ohmyzsh plugins/pyenv
    # zgenom ohmyzsh plugins/python
    # zgenom ohmyzsh plugins/ripgrep
    # zgenom ohmyzsh plugins/systemd

    zgenom load apachler/zsh-aws
    zgenom load hlissner/zsh-autopair
    zgenom load lukechilds/zsh-better-npm-completion
    zgenom load zsh-users/zsh-autosuggestions
    zgenom load zsh-users/zsh-completions src
    zgenom load zsh-users/zsh-history-substring-search
    zgenom load zsh-users/zsh-syntax-highlighting

    zgenom compile ${HOME}/.zshrc
fi

bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget
bindkey '^R' fzf-history-widget

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey '^b' backward-word
bindkey '^f' forward-word

if [ -x "$(command -v keychain)" ]; then
    keychain --absolute --dir "${XDG_RUNTIME_DIR}/keychain" $(find ~/.ssh -iname 'id_*' ! -name '*.pub')
    [[ -f ${XDG_RUNTIME_DIR}/keychain/$HOST-sh ]] && source ${XDG_RUNTIME_DIR}/keychain/$HOST-sh
    [[ -f ${HOME}/.keychain/$HOST-sh ]] && source ${HOME}/.keychain/$HOST-sh
    [[ -f ${HOME}/.keychain/$HOST-sh-gpg ]] && source ${HOME}/.keychain/$HOST-sh-gpg
fi

[[ -d "$HOME/bin" ]] && _extend_path "$HOME/bin"
[[ -d "$XDG_LOCAL/bin" ]] && _extend_path "$XDG_LOCAL/bin"
[[ -d "$GOPATH/bin" ]] && _extend_path "$GOPATH/bin"
[[ -d "$XDG_DATA_HOME/gem/bin" ]] && _extend_path "$XDG_DATA_HOME/gem/bin"
[[ -d "$XDG_DATA_HOME/npm/bin" ]] && _extend_path "$XDG_DATA_HOME/npm/bin"
[[ -d "$CARGO_HOME/bin" ]] && _extend_path "$CARGO_HOME/bin"
[[ -d "/usr/lib/ccache/bin" ]] && _extend_path "/usr/lib/ccache/bin"
[[ -d "/usr/lib/distcc/bin" ]] && _extend_path "/usr/lib/distcc/bin"

[ -x "$(command -v poetry)" ] && poetry completions zsh > ~/.zfunc/_poetry
[ -x "$(command -v pipx)" ] && eval "$(register-python-argcomplete pipx)"
[ -x "$(command -v uv)" ] && eval "$(uv generate-shell-completion zsh)"
[ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
[ -x "$(command -v direnv)" ] && eval "$(direnv hook zsh)"
[ -x "$(command -v mise)" ] && eval "$(mise activate)"


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

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/serkan/.lmstudio/bin"
# End of LM Studio CLI section

if [[ "$OSTYPE" == "darwin"* ]]; then
  export XDG_RUNTIME_DIR="${HOME}/run"
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
