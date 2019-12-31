.PHONY: docker docker-build docker-push

_conf_docker := $(shell [ -f ./Dockerfile ] && echo y || echo n)

_help_target_docker := Builds and pushes a Docker container
_help_target_docker-push := Builds and pushes a Docker container
_help_target_docker-build := Builds a Docker container locally
_help_confvar_REPO := Docker repository/tag for container (excluding the version)

.PHONY: docker docker-build docker-push
$(call overridable,docker): docker-push

ifeq ($(_conf_docker), y)
$(call overridable,docker-build): docker-prerequisites build-docker
	$(call inform,Building docker container)
	$(silent)docker build --no-cache -t $(REPO):$(VERSION) .

$(call overridable,docker-push): docker-build
	$(call inform,Pushing docker container)
	$(silent)docker push $(REPO):$(VERSION)

.PHONY: docker-prerequisites
docker-prerequisites:
	$(call fail-if, [ -n "$(REPO)" ], docker repository is not defined; please create the REPO file)

else

$(call overridable,docker-push): docker-build
	$(call inform,No Dockerfile in root directory -- not pushing a docker container)

$(call overridable,docker-build):
	$(call inform,No Dockerfile in root directory -- not building a docker container)

endif
