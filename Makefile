TYPE=go
REPO=chanetd/mftest

include build/*.mk

.PHONY: all
all: docker-push
