# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same successive entries.
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

eval "$(starship init bash)"

export HISTIGNORE="&:ls:[bf]g:exit:cd:ls"

shopt -s cmdhist
shopt -s histappend

alias resrc='source ~/.bashrc'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
fi

if [[ -d "$HOME/.local/share/bash-completion" ]]; then
	for f in $HOME/.local/share/bash-completion/*; do
		source $f
	done
fi
source ${HOME}/.aliases

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/serkan/.lmstudio/bin"
# End of LM Studio CLI section


alias claude-mem='bun "/home/serkan/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi

# >>> herdr-hibernate pane stub hook >>>
# Re-arm a hibernated agent session when Herdr spawns a fresh shell in a pane.
# This is what makes hibernation survive a reboot: the stub process dies with
# Herdr, but its script lives on disk and this hook runs it again.
# Run it as a CHILD (no exec) so this shell stays the pane's shell — claude is
# then a grandchild, and killing it at the next hibernation cannot close the tab.
if [ -n "${HERDR_PANE_ID:-}" ] && [ -z "${HERDR_HIBERNATE_STUB:-}" ] \
   && [[ $- == *i* ]]; then
    _hb_stub_file="$HOME/.config/herdr-hibernate/panes/${HERDR_PANE_ID//[^A-Za-z0-9]/_}.sh"
    if [ -s "$_hb_stub_file" ]; then
        HERDR_HIBERNATE_STUB=1 bash "$_hb_stub_file"
    fi
    unset _hb_stub_file
fi
# <<< herdr-hibernate pane stub hook <<<
