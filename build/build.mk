_help_target_build-docker := Build binaries for inclusion in Docker container
.PHONY: default/build-docker
default/build-docker:
	$(unimplemented)

_help_target_build-local := Build all packages for the local machine
.PHONY: default/build-local
default/build-local:
	$(unimplemented)

_help_target_test := Runs all tests
.PHONY: default/test
default/test:
	$(unimplemented)

_help_target_lint := Runs the linter
.PHONY: default/lint
default/lint:
	$(unimplemented)
