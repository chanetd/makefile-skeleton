TYPE=go
REPO=chanetd/mftest
GIT_HOOKS=pre-commit
FORCE_GIT_HOOKS=y

include build/*.mk

.DEFAULT_GOAL=all

.PHONY: all
all: docker-push
