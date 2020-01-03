.DEFAULT_GOAL := build-local

VERSION ?= 0.0.1-SNAPSHOT

PRERELEASE_CHECKS ?= test lint
_help_confvar_PRERELEASE_CHECKS := list of Makefile targets that perform prerelease checks (current: $(PRERELEASE_CHECKS))

BINDIRS?=$(shell find ./cmd -maxdepth 1 -mindepth 1 -type d || true)
_help_confvar_BINDIRS := list of package directories that serve as root packages for statically built binaries (current: $(BINDIRS))

EDITOR ?= vi
_help_var_EDITOR := your preferred editor for editing release notes (current: $(EDITOR))
