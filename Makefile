# vim: set noet spell:
PWD=$(shell pwd)
XDG_CACHE_HOME ?= $(HOME)/.cache
XDG_CONFIG_HOME ?= $(HOME)/.config
OHMYZSH = $(XDG_CACHE_HOME)/oh-my-zsh
RSYNCOPTS=--progress --recursive --links --times -D --delete -v
CLEAN_TARGETS=$(shell grep ": out " Makefile | grep -v TARGET | cut -d ':' -f1)
INSTALL_TARGETS=$(shell grep ": in " Makefile | grep -v TARGET | cut -d':' -f1)


.PHONY: $(MAKECMDGOALS)


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | tr -d '{}' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


in:  # this is a dummy target for installers

out:  # this is a dummy target for cleaners


zsh: in aliases profile  ## Sets up zsh {
	stow -R zsh

clean-zsh: out  ## remove zsh config
	stow -D zsh

# }

profile:  ## Sets up profile {
	stow -R profile

clean-profile:
	stow -D profile

# }

starship:  ## Sets up starship {
	stow -R starship

clean-starship:
	stow -D starship

# }

aliases:  ## Sets up aliases {
	stow -R aliases

clean-aliases:
	stow -D aliases

# }

bash: in aliases profile  ## install bash config {
	stow -R bash

clean-bash: clean-bashrc  ## remove bash config
	stow -D bash

# }

tmux: in  ## Install tmux {
	stow -R tmux
	mkdir -p $(HOME)/.tmux/plugins ; \
	$(MAKE) tpm

tpm:  ## Install tmux plugin manager
	if [ ! -e $(HOME)/.tmux/plugins/tpm ]; then \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm ; \
	else \
		cd $(HOME)/.tmux/plugins/tpm && git pull ; \
	fi

clean-tmux: out
	stow -D tmux
	rm -rf ~/.tmux

# }

wezterm: in  ## Install wezterm {
	stow -R wezterm
# }

clean-wezterm: out
	stow -D wezterm
# }

nvim: in ## install neovim config {
	stow -R nvim

clean-nvim: out ## remove neovim
	stow -D nvim
	rm -rf $(XDG_CONFIG_HOME)/nvim $(XDG_CACHE_HOME)/nvim $(XDG_DATA_HOME)/nvim $(XDG_DATA_HOME)/nvim

# }

tilix: in ## install tilix configs {
	stow -R tilix

clean-tilix: out
	stow -D tilix

# }

python: in  ## install python/pdb config {
	stow -R python

pipx: in  ## installs pipx packages
	pipx install --force pre-commit
	pipx install --force pew
	pipx install --force sourcery-cli
	pipx install --force poetry
	pipx install --force invoke
	pipx install --force mycli
	pipx install --force pgcli
	pipx install --force python-lsp-server
	pipx inject python-lsp-server pylsp-rope pylsp-mypy python-lsp-black pylsp-mypy

pipx-update:  ## update all pipx installs
	pipx upgrade-all

clean-pipx: out  ## uninstalls pipx packages
	pipx uninstall-all

python-rebuild:  ## installs user packages
	pip3 freeze | xargs -r pip3 uninstall -y
	$(MAKE) python-user

clean-python: out  ## remove python/pdb config
	stow -D python

# }

alacritty: in  ## install alacritty config {
	stow -R alacritty

clean-alacritty: out  ## remove alacritty config
	stow -D alacritty

# }

foot: in  ## install foot config {
	stow -R foot

clean-foot: out  ## remove foot config
	stow -D foot

# }

kitty: in  ## install kitty config {
	stow -R kitty

clean-kitty: out  ## remove kitty config
	stow -D kitty

# }

npm: in  ## install npm config {
	stow -R npm

clean-npm: out
	stow -D npm

# }

ctags: in  ## install ctags config {
	stow -R ctags

clean-ctags: out
	stow -D ctags

# }

eslint: in  ## install eslint config {
	stow -R eslint

clean-eslint: out
	stow -D eslint

# }

hg: in  ## install hg config {
	stow -R hg

clean-hg: out
	stow -D hg

# }

git: in  ## install git config {
	stow -R git

clean-git: out
	stow -D git

# }

pacman: in  ## install pacman config {
	stow -R pacman

clean-pacman: out
	stow -D pacman

# }

gem: in  ## install gem config {
	stow -R gem

clean-gem: out
	stow -D gem

# }

input: in  ## install input config {
	stow -R input

clean-input: out
	stow -D input

# }

pg: in  ## install postgres config {
	stow -R pg
	mkdir -p $(XDG_CONFIG_HOME)/pg $(XDG_CACHE_HOME)/pg

clean-pg: out
	stow -D pg
	rm -rf $(XDG_CONFIG_HOME)/pg $(XDG_CACHE_HOME)/pg

# }

youtubedl: in  ## install youtube-dl config {
	stow -R youtubedl

clean-youtubedl: out
	stow -D youtubedl

# }

# gnome stuff {
GNOME_BACKUP_KEYS=\
	"com" \
	"org/gnome/terminal" \
	"org/gnome/desktop" \
	"org/gnome/shell" \
	"org/gnome/mutter" \
	"org/gnome/nautilus" \
	"org/gnome/gnome-session" \
	"org/gnome/settings-daemon"

GNOME_BACKUP_PER_MACHINE="org/gnome/shell/favorite-apps"

gnome-backup:
	for g in $(GNOME_BACKUP_KEYS); do \
		mkdir -p dconf/$$g ; \
		dconf dump /$$g/ > dconf/$$g/backup ; \
	done ; \
	for g in $(GNOME_BACKUP_PER_MACHINE); do \
		dconf read /$$g > dconf/$$g.$$HOSTNAME ; \
	done

gnome-restore:
	for g in $(GNOME_BACKUP_KEYS); do \
		dconf reset -f /$$g/ ; \
		dconf load /$$g/ < dconf/$$g/backup ; \
	done ; \
	for g in $(GNOME_BACKUP_PER_MACHINE); do \
		dconf write /$$g "$$(cat dconf/$$g.$$HOSTNAME)" ; \
	done
# }

brew: brew-tap ## installs brew stuff {
	brew install $$(cat Brewfile)
	brew cask install $$(cat Brewfile.cask)

brew-tap:  ## install brew taps
	brew tap $$(cat Brewfile.tap)

brew-update:  ## update brewfiles
	brew leaves | sort > Brewfile
	brew cask list > Brewfile.cask
	brew tap > Brewfile.tap

# }

install: $(INSTALL_TARGETS)  ## installs all

clean: $(CLEAN_TARGETS)  ## removes all

push:  ## push config to another machine with REMOTE
	rsync $(RSYNCOPTS) $(OPTS) \
		$(shell pwd)/ \
		$(REMOTE):$(shell pwd)/ \

pull:  ## pull config from another machine with REMOTE
	rsync $(RSYNCOPTS) $(OPTS) \
		$(REMOTE):$(shell pwd)/ \
		$(shell pwd)/ \
