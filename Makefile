# brew cask install docker

.PHONY: up
up:
	docker-compose up --build
	
.PHONY: docker-run
docker-run:
	swift run Run serve -b 0.0.0.0
	
.PHONY: xcodegen
xcodegen:
	swift package generate-xcodeproj
	
.PHONY: update
update:
	swift package update