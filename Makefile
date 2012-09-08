all: update

update:
	@git submodule init
	@git submodule status | awk '{ print $$2 }' | xargs -r git submodule update
	@git submodule foreach git remote update
	@git submodule foreach git reset --hard

helptags:
	@vim -u NONE -c "\
	for dir in split(globpath(&runtimepath, 'bundle/*/doc/.'), '\n') | \
		execute 'helptags '. dir | \
	endfor" -c quit

#-----------------------------------------------------------------------------

to ?= $(notdir $(basename $(from)))

add:
ifndef from
	#
	# Adds a bundle from any Git repository.
	#
	# * GIT_REPO_URL is the URL of the Git repository.
	# * BUNDLE_NAME is the name of the bundle subdirectory.
	#
	# Usage: make add from=GIT_REPO_URL [to=BUNDLE_NAME]
	#
	@false
endif
	git submodule add $(from) .vim/bundle/$(to)
	git commit -m 'add $(to) bundle' .vim/bundle/$(to) .gitmodules

add-script:
ifndef from
	#
	# Adds a bundle from the http://vim-scripts.org Git mirror.
	#
	# * MIRROR_NAME is the basename of the Git repository.
	# * BUNDLE_NAME is the name of the bundle subdirectory.
	#
	# Usage: make add-script from=MIRROR_NAME [to=BUNDLE_NAME]
	#
	@false
endif
	git submodule add git://github.com/vim-scripts/$(basename $(from)).git .viundle/$(to)
	git commit -m 'add $(to) bundle' bundle/$(to) .gitmodules

remove: .gitmodules
ifndef from
	#
	# Removes a bundle.
	#
	# * BUNDLE_NAME is the name of the bundle subdirectory.
	#
	# Usage: make remove from=BUNDLE_NAME
	#
	@false
endif
	git rebase HEAD # ensure that there are no uncommitted changes
	git rm --cached .vim/bundle/$(from)
	sed -i '/^\[submodule "bundle\/$(from)"\]$$/,+2d' .gitmodules
	git commit -am 'remove $(from) bundle'
	rm -rf .vim/bundle/$(from)