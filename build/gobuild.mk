BINDIRS?=$(shell find ./cmd -maxdepth 1 -mindepth 1 -type d)
_help_confvar_BINDIRS := list of package directories that serve as root packages for statically built binaries (current: $(BINDIRS))

_vendor_arg := $$( [ -d vendor ] && echo '-mod=vendor' )
_static_build_cmd := CGO_ENABLED=0 GOOS=linux go build -tags 'netgo osuersgo' -ldflags '-extldflags "-static"' $(_vendor_arg) .
_quick_build_cmd := go build -i $(_vendor_arg) .

define build-one # args: dir, build command
$(call inform, Building $(1))
$(silent)cd $(1) && $(2)

endef

_help_target_staticbuild := Statically build all the binaries in \$$BINDIRS
.PHONY: staticbuild
$(call overridable,staticbuild):
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_static_build_cmd)))

_help_target_compile := Build all binary packages in \$$BINDIRS (if not empty, builds all packages otherwise)
.PHONY: compile
$(call overridable,compile):
ifneq ($(strip $(BINDIRS)), )
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_quick_build_cmd)))
else
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
