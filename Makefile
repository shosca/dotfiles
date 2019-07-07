# vim: set noet foldmarker={,} foldlevel=0 foldmethod=marker spell:
PWD=$(shell pwd)
XDG_CACHE_HOME ?= $(HOME)/.cache
XDG_CONFIG_HOME ?= $(HOME)/.config
OHMYZSH = $(XDG_CACHE_HOME)/oh-my-zsh
RSYNCOPTS=--progress --recursive --links --times -D --delete -v
CLEAN_TARGETS=$(shell grep ": out " Makefile | grep -v TARGET | cut -d ':' -f1)
INSTALL_TARGETS=$(shell grep ": in " Makefile | grep -v TARGET | cut -d':' -f1)

SYMS=\
	ackrc \
	ctags \
	eslintrc \
	gitconfig \
	hgrc \
	inputrc \
	jshintrc \
	profile \
	psqlrc \
	rspec \
	rvmrc \
	tmux.conf \
	bashrc \
	zshrc \
	zprofile \
	yaourtrc

SYMCLEAN=$(addprefix clean-,$(SYMS))


.PHONY: in out zsh/antigen.zsh $(INSTALL_TARGETS) $(CLEAN_TARGETS)


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | tr -d '{}' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


in:  # this is a dummy target for installers

out:  # this is a dummy target for cleaners


zsh: in zshrc zprofile profile ## Sets up zsh {

clean-zsh: out clean-zshrc clean-zprofile ## remove zsh config
	rm -rf $(HOME)/.antigen $(XDG_CACHE_HOME)/oh-my-zsh $(XDG_CONFIG_HOME)/zplug

# }

bash: in bashrc ## install bash config {

clean-bash: clean-bashrc  ## remove bash config

# }

tmux: in tpm tmux.conf  ## Install tmux {
	mkdir -p $(HOME)/.tmux/plugins ; \

tpm:  ## Install tmux plugin manager
	if [ ! -e $(HOME)/.tmux/plugins/tpm ]; then \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm ; \
	else \
		cd $(HOME)/.tmux/plugins/tpm && git pull ; \
	fi

clean-tmux: out clean-tmux.conf
	rm -rf $(HOME)/.tmux/plugins ; \

# }

vim: in vimenv2 vimenv3  ## install vim/neovim config {
	rm -f $(XDG_CONFIG_HOME)/nvim $(HOME)/.vim
	ln -s $(PWD) $(XDG_CONFIG_HOME)/nvim || true ; \
	ln -s $(PWD) $(HOME)/.vim || true ; \

VIMENV=$(XDG_CACHE_HOME)/vim/venv
VIMENV2=$(VIMENV)/neovim2
VIMENV3=$(VIMENV)/neovim3

vimenv: vimenv2 vimenv3

vimenv2:  ## Sets python env for vim
	mkdir -p $(VIMENV)
	python3 -m virtualenv -p python2.7 $(VIMENV2)
	$(VIMENV2)/bin/pip install -U neovim PyYAML ropevim pynvim

vimenv3:  ## Sets python env for vim
	mkdir -p $(VIMENV)
	python3 -m virtualenv -p python3 $(VIMENV3)
	$(VIMENV3)/bin/pip install -U neovim PyYAML ropevim pynvim

clean-vim: out ## remove vim/neovim config
	rm -rf $(XDG_CONFIG_HOME)/nvim $(XDG_CACHE_HOME)/vim $(HOME)/.cache/vimfiler $(HOME)/.vim

# }

tilix: in ## install tilix configs {
	ln -s $(PWD)/tilix $(XDG_CONFIG_HOME)/tilix || true

clean-tilix: out
	rm -rf $(XDG_CONFIG_HOME)/tilix

# }

python: in  ## install python/pdb config {
	mkdir -p $(XDG_CONFIG_HOME)/python
	ln -sf $(PWD)/python/pylintrc $(XDG_CONFIG_HOME)/pylintrc
	ln -sf $(PWD)/python/pdbrc.py $(HOME)/.pdbrc.py

python-user:  ## installs user packages
	pip3 install --user -U -r user_requirements.txt

clean-python: out  ## remove python/pdb config
	rm -rf $(HOME)/.pdbrc $(HOME)/.pdbrc.py

# }

alacritty: in  ## install alacritty config {
	mkdir -p $(XDG_CONFIG_HOME)/alacritty
	ln -sf $(PWD)/alacritty.yml $(XDG_CONFIG_HOME)/alacritty/alacritty.yml

clean-alacritty: out  ## remove alacritty config
	rm -f $(XDG_CONFIG_HOME)/alacritty/alacritty.yml

# }

kitty: in  ## install kitty config {
	mkdir -p $(XDG_CONFIG_HOME)/kitty
	ln -sf $(PWD)/kitty.conf $(XDG_CONFIG_HOME)/kitty/kitty.conf

clean-kitty: out  ## remove kitty config
	rm -f $(XDG_CONFIG_HOME)/kitty/kitty.yml

# }

npm: in  ## install npm config {
	mkdir -p $(XDG_CONFIG_HOME)/npm
	ln -sf $(PWD)/npmrc $(XDG_CONFIG_HOME)/npm/npmrc
# }

$(SYMS): in  ## install config {
	ln -sf $(PWD)/$@ $(HOME)/.$@

$(SYMCLEAN): clean-%:
	rm -f $(HOME)/.$*

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

GNOME_BACKUP_PER_MACHINE=\
												 "org/gnome/shell/favorite-apps"

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

install: $(INSTALL_TARGETS) $(SYMS) ## installs all

clean: $(CLEAN_TARGETS)  ## removes all

push:  ## push config to another machine with REMOTE
	rsync $(RSYNCOPTS) $(OPTS) \
		$(shell pwd)/ \
		$(REMOTE):$(shell pwd)/ \

pull:  ## pull config from another machine with REMOTE
	rsync $(RSYNCOPTS) $(OPTS) \
		$(REMOTE):$(shell pwd)/ \
		$(shell pwd)/ \
