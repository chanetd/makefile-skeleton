ifndef _build_main_mk
include build/main.mk
endif

ifndef _build_prerequisites_mk
_build_prerequisites_mk := y

# add local .bin directory to path
export PATH := $(shell pwd)/.bin:$(PATH)

_have_prereq = $(call shell-condition, PATH=$$PATH:./.bin which $(1))
_missing_prereqs = $(strip $(foreach p, $(1), $(if $(call _have_prereq, $(p)), , $(p))))

mandatory-prereqs := $(sort curl jq docker $(mandatory-prereqs-$(TYPE)))
mandatory-missing-prereqs := $(call _missing_prereqs, $(mandatory-prereqs))
ifdef mandatory-missing-prereqs
    $(error The following binaries are missing from your PATH: $(mandatory-missing-prereqs))
endif

installable-prereqs := $(sort $(installable-prereqs-$(TYPE)))
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

endif #_build_prerequisites_mk
