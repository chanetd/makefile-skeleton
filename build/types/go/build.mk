godep_flavor := $(shell ([ -f go.mod ] && echo mod) || ([ -f Gopkg.toml ] && echo dep) || echo none)

ifeq ($(godep_flavor),mod)
_vendor_arg := $$( [ -d vendor ] && echo '-mod=vendor' )
else
_vendor_arg :=
endif
_static_build_cmd := CGO_ENABLED=0 GOOS=linux go build -tags 'netgo osusergo' -ldflags '-extldflags "-static"' $(_vendor_arg) .
_quick_build_cmd := go build -i $(_vendor_arg) .

define build-one # args: dir, build command
$(call inform,Building $(1))
$(silent)cd $(1) && $(2)

endef

.PHONY: go/build-docker
go/build-docker:
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_static_build_cmd)))

.PHONY: go/build-local
go/build-local:
ifneq ($(strip $(BINDIRS)), )
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_quick_build_cmd)))
else
	$(call inform,\$$BINDIRS is empty -- building all packages)
	$(silent)go build -i ./...
endif

.PHONY: go/test
go/test:
	$(call inform,Running go test)
	$(silent)go test ./...

.PHONY: go/lint
go/lint:
	$(call inform,Linting)
	$(silent)golangci-lint run
