ifndef _build_main_mk
include build/main.mk
endif

ifndef _build_help_mk
_build_help_mk := y

define _help_message
$(WHITE)USAGE$(NORMAL)

$(GREEN)Targets:$(NORMAL)
 $(foreach hv,$(sort $(filter _help_target_%,$(.VARIABLES))),$(hv:_help_target_%=%): $(value $(hv))$(nl))
$(GREEN)Variables:$(NORMAL)
 $(foreach hv,$(sort $(filter _help_var_%,$(.VARIABLES))),$(hv:_help_var_%=%): $(value $(hv))$(nl))

$(WHITE)CONFIGURATION$(NORMAL)

$(YELLOW)Makefile$(NORMAL)
$(GREEN)Configuration Variables:$(NORMAL)
 $(foreach hv,$(sort $(filter _help_confvar_%,$(.VARIABLES))),$(hv:_help_confvar_%=%): $(value $(hv))$(nl))
endef

.PHONY: help
help:
	$(call say,$(NORMAL),$(_help_message))

# override logic:
# lowest precedence is default implementation (in build/*.mk)
# then type-specific implementation (in build/types/$(TYPE)/*.mk)
# highest precedence is overrides in user Makefiles
#
%: $(TYPE)/% ;

$(TYPE)/%: default/% ;

default/%:
	$(call fatal,Unknown target '$(shell basename $@)' -- type 'make help' for usage instructions)

endif #_build_help_mk
