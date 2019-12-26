BINDIRS?=$(shell find ./cmd -maxdepth 1 -mindepth 1 -type d)

_vendor_arg := $$( [ -d vendor ] && echo '-mod=vendor' )
_static_build_cmd := CGO_ENABLED=0 GOOS=linux go build -tags 'netgo osuersgo' -ldflags '-extldflags "-static"' $(_vendor_arg) .
_quick_build_cmd := go build -i $(_vendor_arg) .

define build-one # args: dir, build command
$(call inform, Building $(1))
@cd $(1) && $(2)

endef

.PHONY: staticbuild
staticbuild:
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_static_build_cmd)))

.PHONY: compile
compile:
	$(foreach d, $(BINDIRS), $(call build-one, $(d), $(_quick_build_cmd)))

.PHONY: test
test:
	$(call inform, Running go test)
	@go test ./...

.PHONY: lint
lint:
	$(call inform, Linting)
	@golangci-lint run
