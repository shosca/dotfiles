# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \n\$ '

# Comment in the above and uncomment this below for a color prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

PROMPT_COMMAND='history -a' # echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    #alias dir='ls --color=auto --format=vertical'
    #alias vdir='ls --color=auto --format=long'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'


export HISTIGNORE="&:ls:[bf]g:exit:cd:ls"

shopt -s cmdhist
shopt -s histappend

# enable color support of ls and also add handy aliases
eval `dircolors -b`
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

export PKG_CONFIG_PATH=/usr/lib/pkgconfig

PATH="${HOME}/bin:${PATH}"

alias alert='notify-send -i gnome-terminal "[$?] $(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/;\s*alert$//'\'')"'
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

SSHAGENT=/usr/bin/ssh-agent
SSHAGENTARGS="-s"

if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then
	eval `$SSHAGENT $SSHAGENTARGS`
	trap "kill $SSH_AGENT_PID" 0
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

if [[ -d "$HOME/.bash_completion.d" ]]; then
	for f in $HOME/.bash_completion.d/* ; do
		source $f
	done
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
[[ -s "$HOME/.rvm/scripts/completion" ]] && source "$HOME/.rvm/scripts/completion"
