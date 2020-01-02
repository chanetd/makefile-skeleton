os := $(shell go env GOHOSTOS)
arch := $(shell go env GOHOSTARCH)

mandatory-prereqs-go :=
installable-prereqs-go := license-detector golangci-lint

.PHONY: install-license-detector
install-license-detector: .bin
	$(call inform,Installing license-detector)
	$(silent)curl -sfL https://github.com/src-d/go-license-detector/releases/download/v3.0.2/license-detector.$(os)_$(arch).gz | gunzip > .bin/license-detector
	$(silent)chmod +x .bin/license-detector

.PHONY: install-golangci-lint
install-golangci-lint: .bin
	$(call inform,Installing golangci-lint)
	$(silent)curl -sfL https://github.com/golangci/golangci-lint/releases/download/v1.21.0/golangci-lint-1.21.0-$(os)-$(arch).tar.gz | tar xz -C .bin
	$(silent)mv $$(find ./.bin -name golangci-lint) ./.bin
	$(silent)rm -rf ./.bin/golangci-lint-*
	$(silent)chmod +x ./.bin/golangci-lint


