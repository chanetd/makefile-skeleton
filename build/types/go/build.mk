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

.PHONY: build-docker-go
build-docker-go:
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_static_build_cmd)))

.PHONY: build-local-go
build-local-go:
ifneq ($(strip $(BINDIRS)), )
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_quick_build_cmd)))
else
	$(call inform,\$$BINDIRS is empty -- building all packages)
	$(silent)go build -i ./...
endif

.PHONY: test-go
test-go:
	$(call inform,Running go test)
	$(silent)go test ./...

.PHONY: lint-go
lint-go:
	$(call inform,Linting)
	$(silent)golangci-lint run
