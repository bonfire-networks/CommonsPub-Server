.PHONY: help dev-exports dev-build dev-deps dev-db dev-test-db dev-test dev-setup dev

ORG_NAME=haha
APP_NAME=commonspub
APP_DOTENV=config/docker.env
APP_DEV_DOTENV=config/docker.dev.env
APP_DEV_DOCKERCOMPOSE=docker-compose.dev.yml
APP_DOCKER_REPO="$(ORG_NAME)/$(APP_NAME)"
APP_DEV_CONTAINER="$(ORG_NAME)_$(APP_NAME)_dev"
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
APP_BUILD ?= `git rev-parse --short HEAD`

init: 
	@echo "Running build scripts for $(APP_NAME):$(APP_VSN)-$(APP_BUILD)"
	@chmod 700 .erlang.cookie 
	@mkdir -p config/prod ; mkdir -p config/dev ; cp -n config/templates/* config/prod/ ; cp -n config/templates/* config/dev/

help: init
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

prepare_for_release:
	@cp lib/*/*/overlay/* rel/overlays/

build_without_cache: init prepare_for_release ## Build the Docker image
	@docker build \
		--no-cache \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) .
	@echo $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD)

build: init prepare_for_release ## Build the Docker image using previous cache
	@docker build \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) .
	@echo $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD)

push: init tag_latest ## Add latest tag to last build and push
	@echo docker push $(APP_DOCKER_REPO):latest
	@docker push $(APP_DOCKER_REPO):latest

tag_latest: init ## Add latest tag to last build 
	@echo docker tag $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) $(APP_DOCKER_REPO):latest
	@docker tag $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) $(APP_DOCKER_REPO):latest

tag_stable: init ## Tag stable, latest and version tags to the last build 
	@echo docker tag $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) $(APP_DOCKER_REPO):$(APP_VSN)
	@docker tag $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) $(APP_DOCKER_REPO):$(APP_VSN)
	@echo docker tag $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) $(APP_DOCKER_REPO):stable
	@docker tag $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) $(APP_DOCKER_REPO):stable

push_stable: init tag_stable ## Tag stable, latest and version tags to the last build and push
	@echo docker push $(APP_DOCKER_REPO):stable
	@docker push $(APP_DOCKER_REPO):stable
	@echo docker push $(APP_DOCKER_REPO):$(APP_VSN)
	@docker push $(APP_DOCKER_REPO):$(APP_VSN)
	@echo docker push $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD)
	@docker push $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD)

hq_deploy_staging: init ## Used by Moodle HQ to trigger deploys to k8s
	@curl https://home.next.moodle.net/devops/respawn/$(MAIL_KEY)
	@curl https://mothership.next.moodle.net/devops/respawn/$(MAIL_KEY)

hq_deploy_stable: init ## Used by Moodle HQ to trigger prod deploys to k8s
	@curl https://home.moodle.net/devops/respawn/$(MAIL_KEY)
	@curl https://team.moodle.net/devops/respawn/$(MAIL_KEY)
	@curl https://mothership.moodle.net/devops/respawn/$(MAIL_KEY)

dev-exports: init ## Load env vars from a dotenv file
	awk '{print "export " $$0}' $(APP_DEV_DOTENV)

dev-pull: init ## Build the dev image
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) pull 

dev-build: init dev-pull ## Build the dev image
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) build 

dev-rebuild: init ## Rebuild the dev image (without cache)
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) build --no-cache

dev-deps: init ## Prepare dev dependencies
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix local.hex --force && mix local.rebar --force && mix deps.get
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web npm install --prefix assets

dev-dep-rebuild: init ## Rebuild a specific library, eg: `make dev-dep-rebuild lib=pointers` 
	sudo rm -rf _build/$(lib)
	sudo rm -rf _build/dev/lib/$(lib)
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web rm -rf _build/$(lib) && mix deps.compile $(lib)

dev-dep-update: init ## Upgrade a dep, eg: `make dev-dep-update lib=plug` 
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix deps.update $(lib)

dev-deps-update-all: init ## Upgrade all deps
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix deps.update --all
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web npm update --prefix assets && npm outdated --prefix assets

dev-db-up: init ## Start the dev DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) up db

dev-search-up: init ## Start the dev search index
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) up search

dev-services-up: init ## Start the dev DB & search index
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) up db search

dev-db-admin: init ## Start the dev DB and dbeaver admin UI
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) up dbeaver 

dev-db: init ## Create the dev DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix ecto.create

dev-db-rollback: init ## Reset the dev DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix ecto.rollback

dev-db-reset: init ## Reset the dev DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix ecto.reset

dev-db-migrate: init ## Run migrations on dev DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix ecto.migrate

dev-db-seeds: init ## Insert some test data in dev DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix ecto.seeds

dev-test-db: init ## Create or reset the test DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run -e MIX_ENV=test web mix ecto.reset

dev-test: init ## Run tests
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix test $(dir)

dev-psql: init ## Run postgres (without Docker)
	psql -h localhost -U postgres $(APP_DEV_CONTAINER)

dev-test-psql: init ## Run postgres for tests (without Docker)
	psql -h localhost -U postgres "$(APP_NAME)_test"

dev-setup: dev-deps dev-db dev-db-migrate ## Prepare dependencies and DB for dev

dev-run: init ## Run a custom command in dev env, eg: `make dev-run cmd="mix deps.update plug`
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web $(cmd)

dev: init ## Run the app in dev 
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run --service-ports web

dev-stop: init ## Stop the dev app
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) stop

dev-down: init ## Remove the dev app
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) down

dev-docs: init ## Remove the dev app
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix docs

manual-deps: init ## Prepare dependencies (without Docker)
	mix local.hex --force
	mix local.rebar --force
	mix deps.get
	npm install --prefix assets

manual-db: init ## Create or reset the DB (without Docker)
	mix ecto.reset

prepare: init ## Run the app in Docker
	docker-compose pull 
	docker-compose build 

run: init ## Run the app in Docker
	docker-compose up 