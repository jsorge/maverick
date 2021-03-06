# brew cask install docker

# https://github.com/vapor/websocket/issues/9
# Needs packages pkg-config & libressl via homebrew on mac
# Needs libssl-dev & pkg-config on Linux

CONTAINER ?= jsorge/maverick
TAG       := $$(git describe --tags)
IMG       := ${CONTAINER}:${TAG}
LATEST    := ${CONTAINER}:latest

.PHONY: dev
dev:
	./tools/update_dev.sh

.PHONY: up
up:
	docker-compose up --build

.PHONY: down
down:
	docker-compose down

.PHONY: docker-run
docker-run:
	swift run Maverick serve -b 0.0.0.0

.PHONY: docker-build
docker-build:
	@docker build -t ${IMG} .
	@docker tag ${IMG} ${LATEST}

.PHONY: docker-push
docker-push:
	docker push ${CONTAINER}
