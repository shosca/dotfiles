PWD=$(shell pwd)
OHMYZSH=.oh-my-zsh
OHMYZSHFILES=\
	$(OHMYZSH) \
	.zshrc
VIMFILES= \
	.vim \
	.vimbackup \
	.viminfo \
	.vimswap \
	.vimundo \
	.vimviews
SYMLINKS= \
	.ackrc \
	.bashrc \
	.bash_profile \
	.profile \
	.ctags \
	.eslintrc \
	.gitconfig \
	.hgrc \
	.inputrc \
	.jshintrc \
	.pdbrc \
	.psqlrc \
	.rspec \
	.rvmrc \
	.tmux.conf \
	.yaourtrc \
	.pdbrc.py

install: install-vim install-zsh install-symlinks install-tmux ## Installs all

install-tmux:
	mkdir -p ~/.tmux/plugins ; \
	if [ ! -e ~/.tmux/plugins/tpm ]; then \
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm ; \
	fi

install-zsh: ## Sets up zsh
	ln -sf $(PWD)/.zshrc ~/.zshrc ; \
	if [ ! -e ~/$(OHMYZSH) ]; then \
		git clone https://github.com/robbyrussell/oh-my-zsh.git ~/$(OHMYZSH) ; \
	else \
		cd ~/$(OHMYZSH) && git pull ; \
	fi

install-vim: ## Sets up vim
	ln -sf $(PWD)/vim ~/.config/nvim ; \
	ln -sf $(PWD)/vim ~/.vim ; \

install-symlinks: ## Symlinks dotfiles into homedir
	for f in $(SYMLINKS); do \
		ln -sf $(PWD)/$$f ~/$$f ; \
	done ; \
	mkdir -p ~/.config/ssh

clean: clean-symlinks clean-vim clean-zsh ## Cleans all configs

clean-symlinks: ## Cleans symlinks and such
	for f in $(SYMLINKS) ; do \
		rm -rf ~/$$f ; \
	done

clean-zsh: ## Cleans zsh config files
	for f in $(OHMYZSHFILES) ; do \
		rm -rf ~/$$f ; \
	done

clean-vim: ## Cleans vim config files
	for f in $(VIMFILES) ; do \
		rm -rf ~/$$f ; \
	done

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

