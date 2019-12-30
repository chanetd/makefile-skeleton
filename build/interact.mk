ifdef V
    silent :=
else
    silent := @
endif
_help_var_V := assign a non-empty value for verbose reporting

# dark-magic trickery to get Make to write out a multi-line value to a file
define nl :=


endef

define escape-newlines
$(subst $(nl),\n,$(1))
endef

# pretty colors
NORMAL=\033[0m
RED=\033[1;31m
GREEN=\033[1;32m
YELLOW=\033[1;33m
BLUE=\033[1;34m
MAGENTA=\033[1;35m
CYAN=\033[1;36m
WHITE=\033[1;37m

define inform # args: message
$(call say,$(WHITE),$(1))
endef

define warn # args: message
$(call say,$(YELLOW),$(1))
endef

define fatal # args: message
$(call say,$(RED),$(1))
@false
endef

define say # args: color, message
@echo -e "$(1)$(call escape-newlines,$(2))$(NORMAL)"
endef

define ask-for-confirmation
$(call inform, $(1))
@read -n 1 -t 10 decision && [ "$$decision" == "y" ]
endef

define shell-condition # args: shell command
$(shell ($(1) > /dev/null 2> /dev/null) && echo y)
endef

define fail-if # args: condition, message
$(if $(call shell-condition, $(1)), $(call fatal,$(2)), )
endef
