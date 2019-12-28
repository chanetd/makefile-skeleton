os := $(shell go env GOHOSTOS)
arch := $(shell go env GOHOSTARCH)

# add local .bin directory to path
export PATH := $(shell pwd)/.bin:$(PATH)

_have_prereq = $(call shell-condition, PATH=$$PATH:./.bin which $(1))
_missing_prereqs = $(strip $(foreach p, $(1), $(if $(call _have_prereq, $(p)), , $(p))))

mandatory-prereqs := curl jq docker
mandatory-missing-prereqs := $(call _missing_prereqs, $(mandatory-prereqs))
ifdef mandatory-missing-prereqs
    $(error The following binaries are missing from your PATH: $(mandatory-missing-prereqs))
endif

installable-prereqs := license-detector golangci-lint
installable-missing-prereqs := $(call _missing_prereqs, $(installable-prereqs))
ifdef installable-missing-prereqs
    ifneq ($(MAKECMDGOALS), install-prerequisites)
    $(error The following prerequisites are not installed: $(installable-missing-prereqs). You can install them \
	locally by running `make install-prerequisites`)
    endif
endif

_help_target_install-prerequisites := Install missing prerequisites in ./.bin
.PHONY: install-prerequisites
install-prerequisites: .bin $(installable-missing-prereqs:%=install-%) ;

# missing prerequisites are installed in ./.bin
.bin:
	$(silent)mkdir -p .bin
	$(silent)[ -f .gitignore ] || (touch .gitignore && git add .gitignore)
	$(silent)grep -q -F .bin/ .gitignore || (echo -e '# locally installed build prerequisites\n.bin/' >> .gitignore && git add .gitignore)

.PHONY: install-license-detector
install-license-detector: .bin
	$(call inform, Installing license-detector)
	$(silent)curl -sfL https://github.com/src-d/go-license-detector/releases/download/v3.0.2/license-detector.$(os)_$(arch).gz | gunzip > .bin/license-detector
	$(silent)chmod +x .bin/license-detector

.PHONY: install-golangci-lint
install-golangci-lint:
	$(call inform, Installing golangci-lint)
	$(silent)curl -sfL https://github.com/golangci/golangci-lint/releases/download/v1.21.0/golangci-lint-1.21.0-$(os)-$(arch).tar.gz | tar xz -C .bin
	$(silent)mv $$(find ./.bin -name golangci-lint) ./.bin
	$(silent)rm -rf ./.bin/golangci-lint-*
	$(silent)chmod +x ./.bin/golangci-lint

