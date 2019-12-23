.PHONY: docker docker-build docker-push

REPO?=$(shell cat REPO)

.PHONY: docker
docker: docker-push ;

.PHONY: docker-build 
docker-build: docker-prerequisites
	docker build -t ${REPO}:${VERSION} .

.PHONY: docker-push
docker-push: docker-build
	docker push ${REPO}:${VERSION}

.PHONY: docker-prerequisites
docker-prerequisites:
	[ -n "$(REPO)" ] || (echo "docker repository is not defined; please create the REPO file" && false)


