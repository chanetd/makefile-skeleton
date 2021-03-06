ifndef _build_main_mk
include build/main.mk
endif

ifndef _build_types_mk
_build_types_mk := y

supported_project_types := $(shell find build/types -maxdepth 1 -mindepth 1 -type d | sed 's@^build/types/@@')
TYPE?=plain
_help_confvar_TYPE := project type (current: $(TYPE), supported: $(supported_project_types))

ifneq ($(filter $(TYPE),$(supported_project_types)),$(TYPE))
    $(error Unsupported project type '$(TYPE)' -- supported types are $(supported_project_types))
endif

include build/types/$(TYPE)/*.mk

endif #_build_types_mk
