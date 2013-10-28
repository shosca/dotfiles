install:
	for f in $$(git ls-files); \
	do \
		rm -f ~/$$f ; ln -sf $(shell pwd)/$$f ~/$$f ; \
	done \

