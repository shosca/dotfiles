export DOTFILES="${HOME}/dotfiles"
export DISABLE_MAGIC_FUNCTIONS=true
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export PEW_DEFAULT_REQUIREMENTS="${DOTFILES}/autoswitch_requires.txt"
export DISABLE_PEW_AUTOACTIVATE="1"

[ -x "$(command -v starship)" ] && eval "$(starship init zsh)"

source_sh() {
  emulate -LR sh
  . "$@"
  emulate -LR zsh
}

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

mkdir -p ~/.zfunc
fpath+=~/.zfunc
[ -x "$(command -v poetry)" ] && poetry completions zsh > ~/.zfunc/_poetry
[ -x "$(command -v pipx)" ] && eval "$(register-python-argcomplete pipx)"

# For ZSH users, uncomment the following two lines:
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
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"
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
REPORTTIME=2
TIMEFMT="%U user %S system %P cpu %*Es total"

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
    zgenom ohmyzsh plugins/archlinux
    zgenom ohmyzsh plugins/aws
    zgenom ohmyzsh plugins/docker
    zgenom ohmyzsh plugins/git
    zgenom ohmyzsh plugins/invoke
    zgenom ohmyzsh plugins/pyenv
    zgenom ohmyzsh plugins/python
    zgenom ohmyzsh plugins/ripgrep
    zgenom ohmyzsh plugins/systemd

    zgenom load apachler/zsh-aws
    zgenom load hlissner/zsh-autopair
    zgenom load lukechilds/zsh-better-npm-completion
    zgenom load pbar1/zsh-terraform
    zgenom load unixorn/fzf-zsh-plugin
    zgenom load zsh-users/zsh-autosuggestions
    zgenom load zsh-users/zsh-completions src
    zgenom load zsh-users/zsh-history-substring-search
    zgenom load zsh-users/zsh-syntax-highlighting

    if [ -d "${HOME}/src/zsh-pew" ]; then
      zgenom load $HOME/src/zsh-pew
    else
      zgenom load shosca/zsh-pew
    fi
    zgenom compile ${HOME}/.zshrc
fi

bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget
bindkey '^R' fzf-history-widget

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey '^b' backward-word
bindkey '^f' forward-word

if [ -f "${HOME}/.ssh/environment-" ]; then
	source ${HOME}/.ssh/environment-
fi
[ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
[ -x "$(command -v direnv)" ] && eval "$(direnv hook zsh)"
