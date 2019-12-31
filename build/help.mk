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

%:
	$(call warn,Unknown target '$@' -- type 'make help' for usage instructions)
	@false
