TYPE=go

include build/main.mk

.PHONY: all
all: docker-push
