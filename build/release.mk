
.PHONY: prerelease-checks
prerelease-checks: test gitclean ;

.PHONY: gitclean
gitclean:
	@git fetch
	@[ -z "`git status --porcelain`" ] || (echo "git is not clean" && false)


.PHONY: release
release: prerelease-checks
	$(MAKE) docker-push VERSION=$(CLEAN_VERSION)
	$(MAKE) set-version VERSION=$(CLEAN_VERSION)
	$(MAKE) tag-release VERSION=$(CLEAN_VERSION)
	$(MAKE) github-make-release VERSION=$(CLEAN_VERSION)
	$(MAKE) set-version VERSION=$(NEXT_VERSION)

.PHONY: tag-release
tag-release: release-notes
	git tag -a v$(VERSION) -F release-notes
	git push -u origin v$(VERSION)
	rm release-notes

# dark-magic trickery to get Make to write out a multi-line value to a file
define nl :=


endef

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

RELNOTES_TEMPLATE_ESCAPED := $(subst $(nl),\n,$(RELNOTES_TEMPLATE))

release-notes:
	@echo -e "$(RELNOTES_TEMPLATE_ESCAPED)" > release-notes
	@$(EDITOR) ./release-notes


# the following variables are lazily evaluated; they only make sense in the release context
_tag_subject=$(shell git tag -l v$(VERSION) --format="%(subject)")
_tag_body=$(shell git tag -l v$(VERSION) --format="%(body)")
_upstream=$(shell git remote show -n origin | grep "Fetch URL" | cut -d ':' -f 2- | sed 's/.*github.com:\?\/\?\([^.]*\)\(\.git\)\?/\1/')
_req=$(shell echo '{}' | jq -c --arg tag "$(VERSION)" --arg name "$(_tag_subject)" --arg body "$(_tag_body)" '.tag_name=$$tag | .name=$$name | .body=$$body')

.PHONY: github-make-release
github-make-release:
	curl -sf -XPOST --data-binary "$(_req)" https://api.github.com/repos/$(_upstream)/releases?access_token=$(GITHUB_TOKEN)


