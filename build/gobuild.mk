_vendor_arg := $$( [ -d vendor ] && echo '-mod=vendor' )
_static_build_cmd := CGO_ENABLED=0 GOOS=linux go build -tags 'netgo osuersgo' -ldflags '-extldflags "-static"' $(_vendor_arg) .
_quick_build_cmd := go build -i $(_vendor_arg) .

define build-one # args: dir, build command
$(call inform,Building $(1))
$(silent)cd $(1) && $(2)

endef

_help_target_build-docker := Build binaries for inclusion in Docker container
.PHONY: build-docker
$(call overridable,build-docker):
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_static_build_cmd)))

_help_target_build-local := Build all packages for the local machine
.PHONY: build-local
$(call overridable,build-local):
ifneq ($(strip $(BINDIRS)), )
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_quick_build_cmd)))
else
	$(call inform,\$$BINDIRS is empty -- building all packages)
	$(silent)go build -i ./...
endif

_help_target_test := Runs all tests
.PHONY: test
$(call overridable,test):
	$(call inform,Running go test)
	$(silent)go test ./...

_help_target_lint := Runs the linter
.PHONY: lint
$(call overridable,lint):
	$(call inform,Linting)
	$(silent)golangci-lint run
