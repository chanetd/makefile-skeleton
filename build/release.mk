define release-message =
You are about to release version $(RELEASE_VERSION) of this project.
The version number will be incremented to $(NEXT_VERSION).
This change will be pushed straight to origin.
Are you sure? (y/n)
endef

_help_confvar_PRERELEASE_CHECKS := list of Makefile targets that perform prerelease checks (current: $(PRERELEASE_CHECKS))
_help_var_GITHUB_TOKEN := GitHub token, needed to create releases on GitHub

.PHONY: prerelease-checks
prerelease-checks: git-is-clean $(PRERELEASE_CHECKS)
	$(call fail-if, [ -z "$$GITHUB_TOKEN" ],GITHUB_TOKEN env var is not set.)
	$(call ask-for-confirmation, $(release-message))

.PHONY: git-is-clean
git-is-clean:
	$(call inform,Checking if the git repository is clean)
	$(silent)git fetch --tags
	$(call fail-if, [ -n "`git status --porcelain`" ],Git is not clean)


_help_target_release := Tag release, update licenses, create release notes and create Github release
.PHONY: release
$(call overridable,release): prerelease-checks
	$(silent)$(MAKE) docker-push VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) update-licenses VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) set-version VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) tag-release VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) github-make-release VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) set-version VERSION=$(NEXT_VERSION)

.PHONY: tag-release
tag-release: release-notes
	$(silent)git tag -a v$(VERSION) -F release-notes
	$(silent)git push -u origin v$(VERSION)
	$(silent)rm release-notes

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
	$(silent)echo -e "$(call escape-newlines, $(RELNOTES_TEMPLATE))" > release-notes
	$(silent)$(EDITOR) ./release-notes


.PHONY: github-make-release
github-make-release:
	$(call inform, Creating github release)
	$(silent)git tag -l v$(VERSION) --format="%(subject)" > .tagsubject
	$(silent)git tag -l v$(VERSION) --format="%(body)" > .tagbody
	$(silent)git ls-remote --get-url | sed 's#.*github.com[:/]##' | sed s'/\.git$$//' > .upstream
	$(silent)echo '{}' | \
	    jq -c --arg tag "$(VERSION)" --arg name "$$(cat .tagsubject)" --arg body \
	    "$$(cat .tagbody)" '.tag_name=$$tag | .name=$$name | .body=$$body' > .req
	$(silent)curl -sf -XPOST --data$(silent)binary @.req https://api.github.com/repos/$$(cat .upstream)/releases?access_token=$(GITHUB_TOKEN)
	$(silent)rm .tagsubject .tagbody .upstream .req


.PHONY: update-licenses
$(call overridable,update-licenses):
	$(call inform, Updating licenses.csv)
	$(silent)go mod tidy
	$(silent)go mod download
	$(silent)echo 'Category,License,Dependency,Notes' > licenses.csv
	$(silent)go list -m -f '{{ .Path }}' all | grep -v Klarrio > .mods
	$(silent)for mod in $$(cat .mods) ; do \
	    modpath=$$(go list -m -f '{{ .Dir }}' $$mod) ; \
	    license=$$(license-detector -f json $$modpath | jq -r '.[0].matches[0].license') ; \
	    echo "$$license,$$license,$$mod," >> licenses.csv ; \
	done
	$(silent)rm .mods
	$(silent)git add licenses.csv
	$(silent)git commit -m "update licenses.csv (auto-generated)"
	$(silent)git push

