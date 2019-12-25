.PHONY: docker docker-build docker-push

REPO?=$(shell cat REPO)

_conf_docker := $(shell [ -f ./Dockerfile ] && echo y || echo n)

.PHONY: docker docker-build docker-push
docker: docker-push

ifeq ($(_conf_docker), y)
docker-build: docker-prerequisites
	$(call inform, Building docker container)
	@docker build -t $(REPO):$(VERSION) .

docker-push: docker-build
	$(call inform, Pushing docker container)
	@docker push $(REPO):$(VERSION)

.PHONY: docker-prerequisites
docker-prerequisites:
	$(call fail-if, [ -n "$(REPO)" ], docker repository is not defined; please create the REPO file)

else

docker-push: docker-build ;

docker-build:
	$(call inform, No Dockerfile in root directory -- not building or pushing a docker container)

endif
