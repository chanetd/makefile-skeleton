ifndef _build_main_mk
include build/main.mk
endif

ifndef _build_hooks_mk
_build_hooks_mk := y

# make sure we don't ask for hooks we can't provide
_available_hooks := $(strip $(foreach hf,$(filter _hook_file_%,$(.VARIABLES)),$(hf:_hook_file_%=%)))
_nonexistent_hooks := $(strip $(filter-out $(_available_hooks),$(GIT_HOOKS)))
ifneq ($(_nonexistent_hooks),)
$(error $$GIT_HOOKS contains the following non-existent hooks: $(_nonexistent_hooks))
endif

_hooks_to_install := $(foreach hook,$(GIT_HOOKS),$(hook):$(value _hook_file_$(hook)))

_help_target_install-hooks := Install git hooks
.PHONY: install-hooks
install-hooks:
	$(silent)for h in $(_hooks_to_install) ; do \
	    hook=$$(echo $$h | sed 's/:.*//') ; \
	    hf=$$(echo $$h | sed 's/.*://') ; \
	    [ ! -x .git/hooks/$$hook ] && cp $$hf .git/hooks/$$hook && chmod +x .git/hooks/$$hook ; \
	    diff -q .git/hooks/$$hook $$hf > /dev/null || echo -e "$(YELLOW)There is an existing $$hook hook that differs from the one we want to install.$(NORMAL)" ; \
	done

_help_confvar_FORCE_GIT_HOOKS := assign a non-empty value to force installation of \$$GIT_HOOKS
ifdef FORCE_GIT_HOOKS
    __:=$(foreach hook,$(GIT_HOOKS),$(shell diff -q $(value _hook_file_$(hook)) .git/hooks/$(hook) > /dev/null 2> /dev/null || \
	(cp $(value _hook_file_$(hook)) .git/hooks/$(hook) && chmod +x .git/hooks/$(hook))))
endif

endif #_build_hooks_mk
