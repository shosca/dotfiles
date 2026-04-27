export DOTFILES="${HOME}/dotfiles"
export DISABLE_MAGIC_FUNCTIONS=true
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"
export REPORTTIME=2
export TIMEFMT="%U user %S system %P cpu %*Es total"
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
export SHOW_AWS_PROMPT=false
export LS_FLAGS="--group-directories-first --time-style=long-iso --sort=name --icons=always"

[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

fpath+=~/.zfunc
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
autoload -U select-word-style

select-word-style bash

setopt always_to_end
setopt append_history
setopt auto_cd
setopt auto_list
setopt auto_menu
setopt auto_param_slash
setopt case_glob
setopt complete_in_word
setopt extended_glob
setopt extended_history
setopt extended_history
setopt glob_dots
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify
setopt inc_append_history
setopt interactive_comments
setopt pushd_ignore_dups
setopt share_history
unsetopt hist_beep
unsetopt menu_complete

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
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' fzf-search-display true
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)*==34=34}:${(s.:.)LS_COLORS}")';

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

zinit pack for dircolors-material
zinit pack for ls_colors

zinit load zsh-users/zsh-completions
zinit load zsh-users/zsh-history-substring-search
zinit load zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions

zinit light junegunn/fzf
zinit light Aloxaf/fzf-tab
zinit light zdharma-continuum/history-search-multi-word
zinit light zdharma-continuum/fast-syntax-highlighting

zinit light apachler/zsh-aws
zinit light hlissner/zsh-autopair

typeset -A key

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -e

key[Home]="$terminfo[khome]"
key[End]="$terminfo[kend]"
key[Insert]="$terminfo[kich1]"
key[Backspace]="$terminfo[kbs]"
key[Delete]="$terminfo[kdch1]"
key[Up]="$terminfo[kcuu1]"
key[Down]="$terminfo[kcud1]"
key[Left]="$terminfo[kcub1]"
key[Right]="$terminfo[kcuf1]"
key[PageUp]="$terminfo[kpp]"
key[PageDown]="$terminfo[knp]"

# setup key accordingly
[[ -n "$key[Home]"      ]] && bindkey -- "$key[Home]"      beginning-of-line
[[ -n "$key[End]"       ]] && bindkey -- "$key[End]"       end-of-line
[[ -n "$key[Insert]"    ]] && bindkey -- "$key[Insert]"    overwrite-mode
[[ -n "$key[Backspace]" ]] && bindkey -- "$key[Backspace]" backward-delete-char
[[ -n "$key[Delete]"    ]] && bindkey -- "$key[Delete]"    delete-char
[[ -n "$key[Up]"        ]] && bindkey -- "$key[Up]"        up-line-or-history
[[ -n "$key[Down]"      ]] && bindkey -- "$key[Down]"      down-line-or-history
[[ -n "$key[Left]"      ]] && bindkey -- "$key[Left]"      backward-char
[[ -n "$key[Right]"     ]] && bindkey -- "$key[Right]"     forward-char

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        echoti smkx
    }
    function zle-line-finish () {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi


bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget
bindkey '^R' fzf-history-widget
bindkey ' ' magic-space

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^b' backward-word
bindkey '^f' forward-word
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search


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

[[ -x "$(command -v fzf)" ]] && source <(fzf --zsh)
[[ -x "$(command -v starship)" ]] && eval "$(starship init zsh)"
[[ -x "$(command -v zoxide)" ]] && eval "$(zoxide init zsh)"

[[ -x $(command -v gwt 2>/dev/null) ]] && eval "$(gwt completions zsh)"
[[ -x $(command -v poetry 2>/dev/null) ]] && poetry completions zsh > ~/.zfunc/_poetry
[[ -x $(command -v pipx 2>/dev/null) ]] && eval "$(register-python-argcomplete pipx)"
[[ -x $(command -v uv 2>/dev/null) ]] && eval "$(uv generate-shell-completion zsh)"
[[ -x $(command -v pyenv 2>/dev/null) ]] && eval "$(pyenv init -)"
[[ -x $(command -v direnv 2>/dev/null) ]] && eval "$(direnv hook zsh)"
[[ -x $(command -v mise 2>/dev/null) ]] && eval "$(mise activate)"

if [[ -f "/usr/bin/dircolors" ]]; then
  case "${TERM}" in
    xterm*)
      export TERM=xterm-256color
      cache_term_colors=256
      eval "$(dircolors -b)"
      ;;
    screen)
      cache_term_colors=256
      eval "$(dircolors -b)"
      ;;
    dumb)
      cache_term_colors=2
      ;;
    *)
      cache_term_colors=16
      eval "$(dircolors -b)"
      ;;
  esac
  if [[ -f ${HOME}/.dircolors ]] && [[ ${cache_term_colors} -ge 8 ]]; then
    eval $(dircolors -b ${HOME}/.dircolors)
  fi
fi


source_sh ${HOME}/.aliases
alias z='__zoxide_z'
alias zi='__zoxide_zi'
alias resrc='source ~/.zshrc'

if [ ! -e ~/.bash-my-aws ]; then
  git clone https://github.com/bash-my-aws/bash-my-aws.git ~/.bash-my-aws
fi
export PATH="$PATH:$HOME/.bash-my-aws/bin"
source_sh ~/.bash-my-aws/aliases
source_sh ~/.bash-my-aws/bash_completion.sh

# if [[ "$OSTYPE" == "darwin"* ]]; then
#   export XDG_RUNTIME_DIR="${HOME}/run"
#   alias nproc="sysctl -n hw.logicalcpu"
#   # handle mac stupidity
#   if [ -f /usr/libexec/path_helper ]; then
#     export PATH=""
#     source /etc/profile
#     export PATH="/usr/local/sbin:${PATH}"
#   fi
#   for _p in $(/usr/bin/find -f /usr/local/Cellar | /usr/bin/grep 'gnubin$' | sort); do
#     _extend_path $_p
#   done
#   export PKG_CONFIG_PATH=""
#   for _p in /usr/local/Cellar/*/*/lib/pkgconfig; do
#     export PKG_CONFIG_PATH="$_p:${PKG_CONFIG_PATH}"
#   done
#
#   export XDG_RUNTIME_DIR="${TMPDIR}"
# fi

# if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
#
