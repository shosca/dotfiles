PWD=$(shell pwd)
XDG_CACHE_HOME ?= $(HOME)/.cache
XDG_CONFIG_HOME ?= $(HOME)/.config
OHMYZSH = $(XDG_CACHE_HOME)/oh-my-zsh
RSYNCOPTS=--progress --recursive --links --times -D --delete -v

SYMLINKS= \
	ackrc \
	bash_profile \
	bashrc \
	ctags \
	eslintrc \
	gitconfig \
	hgrc \
	inputrc \
	jshintrc \
	pdbrc \
	profile \
	psqlrc \
	rspec \
	rvmrc \
	tmux.conf \
	yaourtrc \

.PHONY: help python vim

install: vim zsh symlinks tmux ## Installs all

tpm:  ## Install tmux plugin manager
	if [ ! -e $(HOME)/.tmux/plugins/tpm ]; then \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm ; \
	else \
		cd $(HOME)/.tmux/plugins/tpm && git pull ; \
	fi

tmux: tpm  ## Install tmux
	mkdir -p $(HOME)/.tmux/plugins ; \

oh-my-zsh:
	if [ ! -e $(OHMYZSH) ]; then \
		git clone https://github.com/robbyrussell/oh-my-zsh.git $(OHMYZSH) ; \
	else \
		cd $(OHMYZSH) && git pull ; \
	fi

zsh: oh-my-zsh ## Sets up zsh
	ln -sf $(PWD)/zshrc $(HOME)/.zshrc ; \

vim: ## Sets up vim
	ln -s vim $(XDG_CONFIG_HOME)/nvim || true ; \
	ln -s vim $(HOME)/.vim || true ; \

symlinks:  ## Symlinks dotfiles into homedir
	for f in $(SYMLINKS); do \
		ln -sf $(PWD)/$$f $(HOME)/.$$f ; \
	done ; \
	mkdir -p $(XDG_CACHE_HOME)/ssh
	chmod 600 -R $(XDG_CACHE_HOME)/ssh

python:  # Sets up python related files
	mkdir -p $(XDG_CONFIG_HOME)/python
	ln -sf $(PWD)/python/sitecustomize.py $(XDG_CONFIG_HOME)/python/sitecustomize.py
	ln -sf $(PWD)/python/pdbrc $(HOME)/.pdbrc
	ln -sf $(PWD)/python/pdbrc.py $(HOME)/.pdbrc.py

clean: clean-symlinks clean-vim clean-zsh ## Cleans all configs

clean-symlinks: ## Cleans symlinks and such
	for f in $(SYMLINKS) ; do \
		rm -rf $(HOME)/.$$f ; \
	done

clean-zsh: ## Cleans zsh config files
	rm -rf $(HOME)/.zshrc $(XDG_CACHE_HOME)/.oh-my-zsh

clean-vim: ## Cleans vim config files
	rm -rf $(XDG_CONFIG_HOME)/nvim $(XDG_CACHE_HOME)/vim $(HOME)/.cache/vimfiler $(HOME)/.vim

clean-python:  ## Clean python files
	rm -rf $(HOME)/.pdbrc
	rm -rf $(HOME)/.pdbrc.py
	rm -rf $(HOME)/.config/python/sitecustomize.py

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

push:
	rsync $(RSYNCOPTS) $(OPTS) \
		$(shell pwd)/ \
		$(REMOTE):$(shell pwd)/ \

pull:
	rsync $(RSYNCOPTS) $(OPTS) \
		$(REMOTE):$(shell pwd)/ \
		$(shell pwd)/ \
