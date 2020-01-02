.PHONY: build-docker-plain
build-docker-plain:
	$(call warn,Don't know how to do build-docker for a plain project)

.PHONY: build-local-plain
build-local-plain:
	$(call warn,Don't know how to do build-local for a plain project)

.PHONY: test-plain
test-plain:
	$(call warn,Don't know how to do test for a plain project)

.PHONY: lint-plain
lint-plain:
	$(call warn,Don't know how to do lint for a plain project)
