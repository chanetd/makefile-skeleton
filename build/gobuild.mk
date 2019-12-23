.PHONY: test staticbuild

COMMANDS?=$(shell find ./cmd -maxdepth 1 -mindepth 1 -type d)

staticbuild:
	@for b in $(COMMANDS); do \
	    cd $$b ; \
	    VENDOR=$$( [ -n "$$(find . -name vendor -type d)" ] && echo '-mod=vendor') ; \
	    CGO_ENABLED=0 GOOS=linux go build -tags 'netgo osusergo' -ldflags '-extldflags "-static"' $$VENDOR . ; \
	    cd - > /dev/null; \
	done

compilecheck:
	@for b in $(COMMANDS); do \
	    cd $$b ; \
	    VENDOR=$$( [ -n "$$(find . -name vendor -type d)" ] && echo '-mod=vendor') ; \
	    go build -o /dev/null -i $$VENDOR . ; \
	    cd - > /dev/null; \
	done

test:
	go test ./...


