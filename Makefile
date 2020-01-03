TYPE=go
REPO=chanetd/mftest

include build/main.mk

.PHONY: all
all: docker-push
