set -a

export DOTFILES="${HOME}/dotfiles"

export DISABLE_MAGIC_FUNCTIONS=true

export ZSH_AUTOSUGGEST_STRATEGY=(history)
export PEW_DEFAULT_REQUIREMENTS="${DOTFILES}/autoswitch_requires.txt"
export DISABLE_PEW_AUTOACTIVATE="1"

. ${HOME}/.profile

export PATH="/home/serkan/.local/cargo/bin:$PATH"

# Created by `userpath` on 2020-09-18 19:49:19
export PATH="$PATH:/home/serkan/.local/bin"
