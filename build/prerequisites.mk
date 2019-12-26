# prerequisites
#  - jq
#  - curl
#  - license-detector (github.com/src-d/go-license-detector)

os := $(shell go env GOHOSTOS)
arch := $(shell go env GOHOSTARCH)

.PHONY: install-prerequisites
install-prerequisites: .bin $(missing-prereqs) ;

.bin:
	@mkdir -p .bin
	@[ -f .gitignore ] || (touch .gitignore && git add .gitignore)
	@grep -q -F .bin/ .gitignore || (echo -e '# locally installed build prerequisites\n.bin/' >> .gitignore && git add .gitignore)

.PHONY: install-license-detector
install-license-detector: .bin
	$(call inform, Installing license-detector)
	@curl -sfL https://github.com/src-d/go-license-detector/releases/download/v3.0.2/license-detector.$(os)_$(arch).gz | gunzip > .bin/license-detector
	@chmod +x .bin/license-detector

