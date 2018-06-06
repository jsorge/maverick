# brew cask install docker

# https://github.com/vapor/websocket/issues/9
# Needs packages pkg-config & libressl via homebrew on mac
# Needs libssl-dev & pkg-config on Linux

.PHONY: up
up:
	docker-compose --verbose up --build
	
.PHONY: down
down:
	docker-compose down
	
.PHONY: docker-run
docker-run:
	swift run Run serve -b 0.0.0.0
	
.PHONY: xcodegen
xcodegen:
	swift package generate-xcodeproj
	
.PHONY: update
update:
	swift package update