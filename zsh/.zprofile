set -a

export DOTFILES="${HOME}/dotfiles"

export DISABLE_MAGIC_FUNCTIONS=true

export ZSH_AUTOSUGGEST_STRATEGY=(history)
export PEW_DEFAULT_REQUIREMENTS="${DOTFILES}/autoswitch_requires.txt"
export DISABLE_PEW_AUTOACTIVATE="1"

. ${HOME}/.profile
