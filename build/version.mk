VERSION?=$(shell cat VERSION)
CLEAN_VERSION:=$(shell echo $(VERSION) | sed 's/-.*$$//')
RELEASE_VERSION:=$(shell echo $(VERSION) | sed 's/-SNAPSHOT$$//')
NEXT_VERSION:=$(shell echo $(CLEAN_VERSION) | awk -F. '{ printf("%d.%d.%d", $$1, $$2, $$3 + 1) }')-SNAPSHOT

.PHONY: set-version
set-version:
	$(call inform, Setting version $(VERSION) in VERSION file)
	@echo -n $(VERSION) > VERSION
	@git add VERSION
	@git commit -m "set version v$(VERSION)"
	@git push
