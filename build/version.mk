ifeq ($(call shell-condition, [ -f version.mk ]),y)
    include version.mk
endif

CLEAN_VERSION:=$(shell echo $(VERSION) | sed 's/-.*$$//')
RELEASE_VERSION?=$(shell echo $(VERSION) | sed 's/-SNAPSHOT$$//')
NEXT_VERSION?=$(shell echo $(CLEAN_VERSION) | awk -F. '{ printf("%d.%d.%d", $$1, $$2, $$3 + 1) }')-SNAPSHOT
_help_var_VERSION := Version for snapshot docker container tagging (current: $(VERSION))
_help_var_RELEASE_VERSION := Version for release, derived from \$$VERSION if unspecified (current: $(RELEASE_VERSION))
_help_var_NEXT_VERSION := Next version to put in version.mk file on release (current: $(NEXT_VERSION))

.PHONY: set-version
$(call overridable,set-version):
	$(call inform,Setting version $(VERSION) in version.mk)
	$(silent)echo VERSION=$(VERSION) > version.mk
	$(silent)git add version.mk
	$(silent)[ -z "$$(git status --porcelain)" ] || (git commit -m "set version v$(VERSION)" && git push)
