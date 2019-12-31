ifeq ($(.DEFAULT_GOAL),)
    .DEFAULT_GOAL := build-local
endif

VERSION ?= 0.0.1-SNAPSHOT

PRERELEASE_CHECKS ?= test lint
_help_confvar_PRERELEASE_CHECKS := list of Makefile targets that perform prerelease checks (current: $(PRERELEASE_CHECKS))

OVERRIDES ?=
_help_confvar_OVERRIDES := build system targets you wish to override in your Makefile

BINDIRS?=$(shell find ./cmd -maxdepth 1 -mindepth 1 -type d || true)
_help_confvar_BINDIRS := list of package directories that serve as root packages for statically built binaries (current: $(BINDIRS))

