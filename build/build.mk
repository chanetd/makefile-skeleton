ifndef _build_main_mk
include build/main.mk
endif

ifndef _build_build_mk
_build_build_mk := y

_help_target_build-local := Build the project
.PHONY: default/build
default/build:
	$(unimplemented)

_help_target_test := Runs all tests
.PHONY: default/test
default/test:
	$(unimplemented)

_help_target_lint := Runs the linter
.PHONY: default/lint
default/lint:
	$(unimplemented)

endif #_build_build_mk
