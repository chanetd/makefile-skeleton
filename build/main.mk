# generic functionality
include build/interact.mk
include build/update.mk
include build/version.mk

include build/defaults.mk

# type-dependent functionality
include build/types.mk
include build/docker.mk
include build/build.mk
include build/prerequisites.mk
include build/release.mk

# keep help last
include build/help.mk
