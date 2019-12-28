VERSION?=$(shell cat VERSION)
CLEAN_VERSION:=$(shell echo $(VERSION) | sed 's/-.*$$//')
RELEASE_VERSION:=$(shell echo $(VERSION) | sed 's/-SNAPSHOT$$//')
NEXT_VERSION:=$(shell echo $(CLEAN_VERSION) | awk -F. '{ printf("%d.%d.%d", $$1, $$2, $$3 + 1) }')-SNAPSHOT

.PHONY: set-version
set-version:
	$(call inform, Setting version $(VERSION) in VERSION file)
	$(silent)echo -n $(VERSION) > VERSION
	$(silent)git add VERSION
	$(silent)git commit -m "set version v$(VERSION)"
	$(silent)git push
