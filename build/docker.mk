_conf_docker := $(shell [ -f ./Dockerfile ] && echo y || echo n)

_help_target_docker-push := Builds and pushes a Docker container
_help_target_docker-build := Builds a Docker container locally
_help_confvar_REPO := Docker repository/tag for container (excluding the version)

.PHONY: default/docker-build default/docker-push

ifeq ($(_conf_docker), y)

default/docker-build: docker-prerequisites build-docker
	$(call inform,Building docker container)
	$(silent)docker build --no-cache -t $(REPO):$(VERSION) .

default/docker-push: docker-build
	$(call inform,Pushing docker container)
	$(silent)docker push $(REPO):$(VERSION)

.PHONY: docker-prerequisites
docker-prerequisites:
	$(call fail-if, [ -n "$(REPO)" ],docker repository is not defined; please define the REPO variable)

else

default/docker-push: docker-build
	$(call inform,No Dockerfile in root directory -- not pushing a docker container)

default/docker-build:
	$(call inform,No Dockerfile in root directory -- not building a docker container)

endif
