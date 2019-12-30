origin_repo := git@github.com:chanetd/makefile-skeleton

_help_target_update-build-system := fetch latest version of build system from $(origin_repo)
.PHONY: update-build-system
update-build-system:
	$(call inform,Updating build system)
	$(silent)-rm -rf .buildupd
	$(silent)mkdir .buildupd
	$(silent)cd .buildupd
	$(silent)git clone $(origin_repo)
	$(silent)-rm -rf build
	$(silent)mv $$(find .buildupd -name build -type d) ./build
	$(silent)rm -rf .buildupd
	$(silent)git add build/*
