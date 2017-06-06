#!/bin/zsh

source_env() {
  if [[ -f .env ]]; then
    set -a
    source .env
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd source_env
