# we need a special release process for go dep projects that 
# vendors all dependencies on a release branch
.PHONY: go/release-git-dep
go/release-git-dep:
	$(call inform,Creating release branch v$(RELEASE_VERSION) to vendor dependencies)
	$(silent)git branch --show-current > .branch
	$(silent)git checkout -b release-v$(RELEASE_VERSION)
	$(silent)dep ensure
	$(silent)git add --force vendor
	$(silent)git commit -a -m "vendoring dependencies for release v$(RELEASE_VERSION)"
	$(silent)git push -u origin release-v$(RELEASE_VERSION)
	$(silent)$(MAKE) set-version VERSION=$(RELEASE_VERSION)
	$(silent)$(MAKE) tag-release VERSION=$(RELEASE_VERSION)
	$(silent)git checkout $$(cat .branch)
	$(silent)$(MAKE) set-version VERSION=$(NEXT_VERSION)
	$(silent)rm .branch

ifeq ($(godep_flavor),dep)

.PHONY: go/release-git
go/release-git: go/release-git-dep ;

endif

# the license extraction process depends on the dependency manager used
.PHONY: go/update-licenses
go/update-licenses: go/update-licenses-$(godep_flavor) ;

.PHONY: go/update-licenses-mod
go/update-licenses-mod:
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

.PHONY: go/update-licenses-dep
go/update-licenses-dep:
	$(call inform,Updating licenses.csv)
	$(silent)dep ensure
	$(silent)echo 'Category,License,Dependency,Notes' > licenses.csv
	$(silent)go list -deps -f '{{.Dir}}' . | grep '/vendor/' | grep -v Klarrio > .deps
	$(silent)for dep in $$(cat .deps) ; do \
	    license=$$(license-detector -f json $$dep | jq -r '.[0].matches[0].license') ; \
	    mod=$$(echo $$dep | sed 's#^.*/vendor/##') ; \
	    echo "$$license,$$license,$$mod," >> licenses.csv ; \
	done
	$(silent)rm .deps
	$(silent)git add licenses.csv
	$(silent)[ -z "$$(git status --porcelain)" ] || (git commit -m "update licenses.csv (auto-generated)" && git push)

.PHONY: go/update-licenses-none
go/update-licenses-none:
	$(call warn,No dependency information -- not updating licenses.csv)
