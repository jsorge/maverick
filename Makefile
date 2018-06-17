# brew cask install docker

# https://github.com/vapor/websocket/issues/9
# Needs packages pkg-config & libressl via homebrew on mac
# Needs libssl-dev & pkg-config on Linux

PROJECT ?= Maverick.xcodeproj

.PHONY: up
up:
	docker-compose up --build
	
.PHONY: down
down:
	docker-compose down
	
.PHONY: docker-run
docker-run:
	swift run Maverick serve -b 0.0.0.0
	
project: $(PROJECT)

$(PROJECT):
	swift package generate-xcodeproj \
		--xcconfig-overrides settings.xcconfig \
		--output $(PROJECT)
	
.PHONY: update
update:
	swift package update
	
.PHONY: serve
serve:
	docker-compose -f docker-compose-prod.yml up --build