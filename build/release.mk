define release-message =
You are about to release version $(RELEASE_VERSION) of this project.
The version number will be incremented to $(NEXT_VERSION).
This change will be pushed straight to origin.
Are you sure? (y/n)
endef

_help_var_GITHUB_TOKEN := GitHub token, needed to create releases on GitHub
_help_var_GITLAB_TOKEN := GitLab token, needed to create releases on GitLab

upstream_flavor := $(shell us=$$(git ls-remote --get-url) ; \
    if ( echo $$us | grep -q github.com ) ; then echo github ; \
    elif ( echo $$us | grep -q gitlab.com ) ; then echo gitlab ; \
    else echo unknown ; \
    fi)

.PHONY: prerelease-checks
prerelease-checks: upstream-token-check-$(upstream_flavor) git-is-clean $(PRERELEASE_CHECKS)
	$(call ask-for-confirmation, $(release-message))

.PHONY: git-is-clean
git-is-clean:
	$(call inform,Checking if the git repository is clean)
	$(silent)git fetch --tags
	$(call fail-if, [ -n "`git status --porcelain`" ],Git is not clean)

.PHONY: upstream-token-check-github
upstream-token-check-github:
	$(call fail-if, [ -z "$$GITHUB_TOKEN" ],GITHUB_TOKEN env var is not set.)

.PHONY: upstream-token-check-gitlab
upstream-token-check-gitlab:
	$(call fail-if, [ -z "$$GITLAB_TOKEN" ],GITLAB_TOKEN env var is not set.)

.PHONY: upstream-token-check-unknown
upstream-token-check-unknown:
	$(call fatal,Unrecognized upstream URL; only github and gitlab upstreams are supported)


_help_target_release := Tag release, update licenses, create release notes and create Github release
.PHONY: release
$(call overridable,release): prerelease-checks
	$(silent)$(MAKE) docker-push VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) update-licenses VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) release-git VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) make-release-$(upstream_flavor) VERSION=$(RELEASE_VERSION)

.PHONY: release-git
release-git:
	$(silent)$(MAKE) release-git-$(godep_flavor)

.PHONY: release-git-mod
release-git-mod:
	$(silent)$(MAKE) set-version VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) tag-release VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) set-version VERSION=$(NEXT_VERSION)

.PHONY: release-git-dep
release-git-dep:
	$(call inform,Creating release branch v$(RELEASE_VERSION) to vendor dependencies)
	$(silent)git branch --show-current > .branch
	$(silent)git checkout -b v$(RELEASE_VERSION)
	$(silent)dep ensure
	$(silent)git add --force vendor
	$(silent)git commit -a -m "vendoring dependencies for release v$(RELEASE_VERSION)"
	$(silent)git push -u origin v$(RELEASE_VERSION)
	$(silent)$(MAKE) set-version VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) tag-release VERSION=$(RELEASE_VERSION)
	$(silent)git checkout $$(cat .branch)
	$(silent)$(MAKE) set-version VERSION=$(NEXT_VERSION)
	$(silent)rm .branch

.PHONY: release-git-none
release-git-none:
	$(silent)$(MAKE) set-version VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) tag-release VERSION=$(RELEASE_VERSION)
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
	$(silent)echo -e "$(call escape-newlines,$(RELNOTES_TEMPLATE))" > release-notes
	$(silent)$(EDITOR) ./release-notes


.PHONY: make-release-github
make-release-github:
	$(call inform,Creating github release)
	$(silent)git tag -l v$(VERSION) --format="%(subject)" > .tagsubject
	$(silent)git tag -l v$(VERSION) --format="%(body)" > .tagbody
	$(silent)git ls-remote --get-url | sed 's#.*github.com[:/]##' | sed s'/\.git$$//' > .upstream
	$(silent)echo '{}' | \
	    jq -c --arg tag "v$(VERSION)" --arg name "$$(cat .tagsubject)" --arg body \
	    "$$(cat .tagbody)" '.tag_name=$$tag | .name=$$name | .body=$$body' > .req
	$(silent)curl -sf -XPOST --data-binary @.req https://api.github.com/repos/$$(cat .upstream)/releases?access_token=$(GITHUB_TOKEN)
	$(silent)rm .tagsubject .tagbody .upstream .req

.PHONY: make-release-gitlab
make-release-gitlab:
	$(call inform,Creating gitlab release)
	$(silent)git tag -l v$(VERSION) --format="%(subject)" > .tagsubject
	$(silent)git tag -l v$(VERSION) --format="%(body)" > .tagbody
	$(silent)git ls-remote --get-url | sed 's#.*gitlab.com[:/]##' | sed s'/\.git$$//' > .upstream
	$(silent)cat .upstream | tr -d '\n' | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3- > .projectpath
	$(silent)echo '{}' | \
	    jq -c --arg tag "v$(VERSION)" --arg name "$$(cat .tagsubject)" --arg body \
	    "$$(cat .tagbody)" '.tag_name=$$tag | .name=$$name | .description=$$body' > .req
	$(silent)curl -sf -XPOST -H 'Content-Type: application/json' --data-binary @.req https://gitlab.com/api/v4/projects/$$(cat .projectpath)/releases?private_token=$(GITLAB_TOKEN)
	$(silent)rm .tagsubject .tagbody .upstream .projectpath .req


.PHONY: update-licenses
$(call overridable,update-licenses):
	$(call inform,Updating licenses.csv)
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
	$(silent)[ -z "$$(git status --porcelain)" ] || (git commit -m "update licenses.csv (auto-generated)" && git push)

