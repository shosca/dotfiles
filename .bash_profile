# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth
export HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

ps_scm_f() {
  local s=
  if [[ -d ".svn" ]] ; then
    local r=$(svn info | sed -n -e '/^Revision: \([0-9]*\).*$/s//\1/p' )
    s="(r$r$(svn status | grep -q -v '^?' && echo -n "*" ))"
  else
    local d=$(git rev-parse --git-dir 2>/dev/null ) b= r= a= c= e= f= g=
    if [[ -n "${d}" ]] ; then
      if [[ -d "${d}/../.dotest" ]] ; then
        if [[ -f "${d}/../.dotest/rebase" ]] ; then
          r="rebase"
        elif [[ -f "${d}/../.dotest/applying" ]] ; then
          r="am"
        else
          r="???"
        fi
        b=$(git symbolic-ref HEAD 2>/dev/null )
      elif [[ -f "${d}/.dotest-merge/interactive" ]] ; then
        r="rebase-i"
        b=$(<${d}/.dotest-merge/head-name)
      elif [[ -d "${d}/../.dotest-merge" ]] ; then
        r="rebase-m"
        b=$(<${d}/.dotest-merge/head-name)
      elif [[ -f "${d}/MERGE_HEAD" ]] ; then
        r="merge"
        b=$(git symbolic-ref HEAD 2>/dev/null )
      elif [[ -f "${d}/BISECT_LOG" ]] ; then
        r="bisect"
        b=$(git symbolic-ref HEAD 2>/dev/null )"???"
      else
        r=""
        b=$(git symbolic-ref HEAD 2>/dev/null )
      fi

      if git status | grep -q '^# Changes not staged' ; then
        a="${a}*"
      fi

      if git status | grep -q '^# Changes to be committed:' ; then
        a="${a}+"
      fi

      if git status | grep -q '^# Untracked files:' ; then
        a="${a}?"
      fi

      e=$(git status | sed -n -e '/^# Your branch is /s/^.*\(ahead\|behind\).* by \(.*\) commit.*/\1 \2/p' )
      if [[ -n ${e} ]] ; then
        f=${e#* }
        g=${e% *}
        if [[ ${g} == "ahead" ]] ; then
          e="+${f}"
        else
          e="-${f}"
        fi
      else
        e=
      fi

      b=${b#refs/heads/}
      b=${b// }
      [[ -n "${b}" ]] && c="$(git config "branch.${b}.remote" 2>/dev/null )"
      [[ -n "${r}${b}${c}${a}" ]] && s="(${r:+${r}:}${b}${c:+@${c}}${e}${a:+ ${a}})"
    fi
  fi
  s="${s:+${s} }"
  echo -n "$s"
}

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(ps_scm_f) \n\$ '

PROMPT_COMMAND='history -a; history -n'

case "${TERM}" in
  xterm*)
    export TERM=xterm-256color
    cache_term_colors=256
    if [[ -f "/usr/bin/dircolors" ]] ; then
      eval "`dircolors -b`"
    fi
    alias ls='ls --color=auto'
    ;;
  screen)
    cache_term_colors=256
    if [[ -f "/usr/bin/dircolors" ]] ; then
      eval "`dircolors -b`"
    fi
    alias ls='ls --color=auto'
    ;;
  dumb)
    cache_term_colors=2
    ;;
  *)
    cache_term_colors=16
    if [[ -f "/usr/bin/dircolors" ]] ; then
      eval "`dircolors -b`"
    fi
    alias ls='ls --color=auto'
    ;;
esac

if [[ -f "/usr/bin/dircolors" ]] && [[ -f ${HOME}/.dircolors ]] && [[ ${cache_term_colors} -ge 8 ]] ; then
  eval $(dircolors -b ${HOME}/.dircolors)
fi

export HISTIGNORE="&:ls:[bf]g:exit:cd:ls"

shopt -s cmdhist
shopt -s histappend

# enable color support of ls and also add handy aliases
alias ls='ls --color=auto'
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias pygrep="grep --include='*.py' $*"
alias rbgrep="grep --include='*.rb' $*"
alias csgrep="grep --include='*.cs' $*"
alias brgrep="grep --include='*.brail' $*"

# some more ls aliases
alias ll='ls -lhX'
alias la='ls -A'
alias ldir='ls -lhA |grep ^d'
alias lfiles='ls -lhA |grep ^-'
alias l='ls -CF'

# To check a process is running in a box with a heavy load: pss
alias pss='ps -ef | grep $1'

# usefull alias to browse your filesystem for heavy usage quickly
#alias ducks='ls -A | grep -v -e '\''^\.\.$'\'' |xargs -i du -ks {} |sort -rn |head -16 | awk '\''{print $2}'\'' | xargs -i du -hs {}'
#lias ducks='for f in ./* ./.*; do du -ks "${f}"; done | sort -rn | head -16'
alias ducks='du -sk * | sort -n | perl -ne '\''($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}'\'

alias search='apt-cache search'
alias c='clear'
alias up='cd ..'

alias radeondynpm='echo dynpm | sudo tee -a /sys/class/drm/card0/device/power_method'
alias radeonprofile='echo profile | sudo tee -a /sys/class/drm/card0/device/power_method'
alias radeonlow='echo low | sudo tee -a /sys/class/drm/card0/device/power_profile'
alias radeonmid='echo mid| sudo tee -a /sys/class/drm/card0/device/power_profile'
alias radeondefault='echo default | sudo tee -a /sys/class/drm/card0/device/power_profile'
alias radeonhigh='echo high | sudo tee -a /sys/class/drm/card0/device/power_profile'
alias drmdebug='echo 14 | sudo tee -a /sys/module/drm/parameters/debug'
alias drmnodebug='echo 0 | sudo tee -a /sys/module/drm/parameters/debug'
alias resrc='source ~/.bashrc'

PATH="${HOME}/bin:${PATH}"

export EDITOR="vim"

alias alert='notify-send -i gnome-terminal "[$?] $(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/;\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

if [[ -d "/usr/lib/ccache/bin" ]]; then
  PATH="/usr/lib/ccache/bin:${PATH}"
fi

if [[ -d "$HOME/.local/share/bash-completion" ]]; then
  for f in $HOME/.local/share/bash-completion/* ; do
    source $f
  done
fi

[[ -s "$HOME/.rvm/scripts/completion" ]] && source "$HOME/.rvm/scripts/completion"

if [[ -d "$HOME/go/bin" ]]; then
  PATH="${HOME}/go/bin:${PATH}"
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
