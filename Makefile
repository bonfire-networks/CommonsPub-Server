.PHONY: help

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
APP_BUILD ?= `git rev-parse --short HEAD`

help:
	@echo "$(APP_NAME):$(APP_VSN)-$(APP_BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build \
		--no-cache \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t moodlenet:$(APP_VSN)-$(APP_BUILD) \
		-t moodlenet:latest .

build_with_cache: ## Build the Docker image
	docker build \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t moodlenet:$(APP_VSN)-$(APP_BUILD) \
		-t moodlenet:latest .

run: ## Run the app in Docker
	docker run\
		--env-file config/docker.env \
		--expose 4000 -p 4000:4000 \
		--rm -it moodlenet:latest
