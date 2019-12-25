define release-message =
You are about to release version $(RELEASE_VERSION) of this project.
The version number will be incremented to $(NEXT_VERSION).
This change will be pushed straight to origin.
Are you sure? (y/n)
endef

.PHONY: prerelease-checks
prerelease-checks: git-is-clean test
	$(call ask-for-confirmation, $(release-message))

.PHONY: git-is-clean
git-is-clean:
	$(call inform, Checking if the git repository is clean)
	@git fetch --tags
	$(call fail-if, [ -n "`git status --porcelain`" ], git is not clean)


.PHONY: release
release: prerelease-checks
	@$(MAKE) docker-push VERSION=$(RELEASE_VERSION)
	@$(MAKE) set-version VERSION=$(RELEASE_VERSION)
	@$(MAKE) tag-release VERSION=$(RELEASE_VERSION)
	@$(MAKE) github-make-release VERSION=$(RELEASE_VERSION)
	@$(MAKE) set-version VERSION=$(NEXT_VERSION)

.PHONY: tag-release
tag-release: release-notes
	@git tag -a v$(VERSION) -F release-notes
	@git push -u origin v$(VERSION)
	@rm release-notes

define RELNOTES_TEMPLATE :=
Release version $(VERSION)

NEW:
- n/a

FIXED:
- n/a

DEPRECATED:
- n/a

# add your release notes above
endef

release-notes:
	@echo -e "$(call escape-newlines, $(RELNOTES_TEMPLATE))" > release-notes
	@$(EDITOR) ./release-notes


.PHONY: github-make-release
github-make-release:
	$(call inform, Creating github release)
	@git tag -l v$(VERSION) --format="%(subject)" > .tagsubject
	@git tag -l v$(VERSION) --format="%(body)" > .tagbody
	@git ls-remote --get-url | sed 's#.*github.com[:/]##' | sed s'/\.git$$//' > .upstream
	@echo '{}' | \
	    jq -c --arg tag "$(VERSION)" --arg name "$$(cat .tagsubject)" --arg body \
	    "$$(cat .tagbody)" '.tag_name=$$tag | .name=$$name | .body=$$body' > .req
	@curl -sf -XPOST --data-binary @.req https://api.github.com/repos/$$(cat .upstream)/releases?access_token=$(GITHUB_TOKEN)
	@rm .tagsubject .tagbody .upstream .req
