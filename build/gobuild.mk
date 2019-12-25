BINDIRS?=$(shell find ./cmd -maxdepth 1 -mindepth 1 -type d)

_vendor_arg := $$( [ -d vendor ] && echo '-mod=vendor' )
_static_build_cmd := CGO_ENABLED=0 GOOS=linux go build -tags 'netgo osuersgo' -ldflags '-extldflags "-static"' $(_vendor_arg) .
_quick_build_cmd := go build -i $(_vendor_arg) .

.PHONY: staticbuild
staticbuild:
	$(foreach d, $(BINDIRS), @cd $(d) && $(_static_build_cmd) $(nl))

.PHONY: compilecheck
compilecheck:
	$(foreach d, $(BINDIRS), @cd $(d) && $(_quick_build_cmd) $(nl))

.PHONY: test
test:
	go test ./...
