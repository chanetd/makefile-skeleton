ifndef _build_main_mk
_build_main_mk := y

# generic functionality
include build/interact.mk
include build/update.mk
include build/version.mk

include build/defaults.mk

# type-specific functionality
include build/types.mk

# the includes below all depend on type-specific overrides
include build/hooks.mk
include build/docker.mk
include build/build.mk
include build/prerequisites.mk
include build/release.mk

# keep help last
include build/help.mk

endif #_build_main_mk
