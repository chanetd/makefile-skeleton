_help_target_build-docker := Build binaries for inclusion in Docker container
.PHONY: $(call overridable, build-docker)
$(call overridable,build-docker): build-docker-$(TYPE)

_help_target_build-local := Build all packages for the local machine
.PHONY: $(call overridable, build-local)
$(call overridable,build-local): build-local-$(TYPE)

_help_target_test := Runs all tests
.PHONY: $(call overridable, test)
$(call overridable,test): test-$(TYPE)

_help_target_lint := Runs the linter
.PHONY: $(call overridable, lint)
$(call overridable,lint): lint-$(TYPE)
