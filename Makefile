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

brew: brew-tap ## installs brew stuff
	brew install $$(cat Brewfile)
	brew cask install $$(cat Brewfile.cask)

brew-tap:  ## install brew taps
	brew tap $$(cat Brewfile.tap)

brew-update:  ## update brewfiles
	brew leaves | sort > Brewfile
	brew cask list > Brewfile.cask
	brew tap > Brewfile.tap

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
