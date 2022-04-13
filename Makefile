SHELL := pwsh -NoProfile

DOCKER_BUILDKIT := 1

build:
	docker build -t rails-builder ./rails-builder-image/