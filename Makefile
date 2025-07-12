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

.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'


in:  # this is a dummy target for installers

out:  # this is a dummy target for cleaners


bin: in aliases profile
	stow -R bin

clean-bin:
	stow -D bin


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
#
direnv:  ## Sets up direnv {
	stow -R direnv

clean-direnv:
	stow -D direnv

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

python-rebuild:  ## installs user packages
	pip3 freeze | xargs -r pip3 uninstall -y

clean-python: out  ## remove python/pdb config
	stow -D python

# }

uvx-jedi-language-server: in
	uv tool install jedi-language-server

clean-uvx-jedi-language-server: out
	uv tool uninstall jedi-language-server

uvx-pylsp: in
	uv tool install --with pylsp-mypy --with pylsp-rope python-lsp-server

clean-uvx-pylsp: out
	uv tool uninstall python-lsp-server

uvx-yawsso: in
	uv tool install yawsso

clean-uvx-yawsso: out
	uv tool uninstall yawsso

uvx-ruff-lsp: in
	uv tool install ruff-lsp

clean-uvx-ruff-lsp: out
	uv tool uninstall ruff-lsp

uvx: in
	$(MAKE) $(shell grep "^uvx-" Makefile | cut -d':' -f1)

clean-uvx: out
	$(MAKE) $(shell grep "^clean-uvx-" Makefile | cut -d':' -f1)


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
