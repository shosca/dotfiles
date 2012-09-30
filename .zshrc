# Path to your oh-my-zsh configuration.
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi

ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="suvash"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git rails ruby python gem node npm rvm vim history-substring-search)

source $ZSH/oh-my-zsh.sh

bindkey "^[[A" history-search-backward

bindkey "^[[B" history-search-forward

# Customize to your needs...
#
alias ls='ls --color=auto'
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias pygrep="grep --include='*.py' $*"
alias rbgrep="grep --include='*.rb' $*"
alias csgrep="grep --include='*.cs' $*"
alias brgrep="grep --include='*.brail' $*"
alias ll='ls -lhX'
alias la='ls -A'
alias ldir='ls -lhA |grep ^d'
alias lfiles='ls -lhA |grep ^-'
alias l='ls -CF'

# To check a process is running in a box with a heavy load: pss
alias pss='ps -ef | grep $1'

# usefull alias to browse your filesystem for heavy usage quickly
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

alias alert='notify-send -i gnome-terminal "[$?] $(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/;\s*alert$//'\'')"'

if [[ -d "$HOME/go/bin" ]]; then
	PATH="${HOME}/go/bin:${PATH}"
fi

if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
	source "$HOME/.rvm/scripts/rvm"
	PATH=$PATH:$HOME/.rvm/bin
fi
