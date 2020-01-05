ifndef _build_main_mk
include build/main.mk
endif

ifndef _build_defaults_mk
_build_defaults_mk := y

.DEFAULT_GOAL := help
_help_confvar_.DEFAULT_GOAL := make default goal (invoked when you run make without targets)

VERSION ?= 0.0.1-SNAPSHOT

PRERELEASE_CHECKS ?= test lint
_help_confvar_PRERELEASE_CHECKS := list of Makefile targets that perform prerelease checks (current: $(PRERELEASE_CHECKS))

GIT_HOOKS ?=
_help_confvar_GIT_HOOKS := list of git hooks that need to be installed for this repository

BINDIRS?=$(shell find ./cmd -maxdepth 1 -mindepth 1 -type d || true)
_help_confvar_BINDIRS := list of package directories that serve as root packages for statically built binaries (current: $(BINDIRS))

EDITOR ?= vi
_help_var_EDITOR := your preferred editor for editing release notes (current: $(EDITOR))

endif #_build_defaults_mk
