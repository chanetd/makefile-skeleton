.PHONY: docker docker-build docker-push

REPO?=$(shell cat REPO)

_conf_docker := $(shell [ -f ./Dockerfile ] && echo y || echo n)

.PHONY: docker docker-build docker-push
docker: docker-$(_conf_docker)
docker-build: docker-build-$(_conf_docker)
docker-push: docker-push-$(_conf_docker)

.PHONY: docker-y
docker-y: docker-push-y

.PHONY: docker-n
docker-n:
	@echo "No Dockerfile in root directory -- not building or pushing a Docker container"

.PHONY: docker-build-y 
docker-build-y: docker-prerequisites-y
	docker build -t ${REPO}:${VERSION} .

.PHONY: docker-build-n
docker-build-n: ;

.PHONY: docker-push-y
docker-push-y: docker-build-y
	docker push ${REPO}:${VERSION}
	
.PHONY: docker-push-n
docker-push-n: ;

.PHONY: docker-prerequisites-y
docker-prerequisites-y:
	[ -n "$(REPO)" ] || (echo "docker repository is not defined; please create the REPO file" && false)
