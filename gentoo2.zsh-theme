# vim:ft=zsh ts=2 sw=2 sts=2

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n "%{$bg%F{$CURRENT_BG}%}%{$fg%}"
  else
    echo -n "%{$bg%}%{$fg%}"
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
  echo "%{$reset_color%}"
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    echo "$fg_bold[green]$USER@%m "
  fi
}

prompt_dir() {
  echo "%{$fg_bold[blue]%}%(!.%1~.%~) "
}

prompt_char() {
  echo "%{$fg_bold[blue]%}$%{$reset_color%}"
}

prompt_venv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment black red "$(basename $virtualenv_path):"
  fi
}

function check_git_prompt_info() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    if [[ -z $(git_prompt_info) ]]; then
      echo "%{$fg[blue]%}detached-head%{$reset_color%}) $(git_prompt_status)"
    else
      echo "$(git_prompt_info) $(git_prompt_status)"
    fi
  fi
}

# Format for git_prompt_info()
ZSH_THEME_GIT_PROMPT_PREFIX="at %{$fg[blue]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%} ✔"
# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?"
# Format for git_prompt_ahead()
ZSH_THEME_GIT_PROMPT_AHEAD=" %{$fg_bold[white]%}^"
# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE=" %{$fg_bold[white]%}[%{$fg_bold[blue]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$fg_bold[white]%}]"

PROMPT='$(prompt_context)$(prompt_dir)$(check_git_prompt_info)
$(prompt_venv)$(prompt_char) '

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=") "
