.PHONY: help dev-exports dev-build dev-deps dev-db dev-test-db dev-test dev-setup dev

APP_NAME=moodle_net
APP_DOTENV=config/docker.env
APP_DEV_DOTENV=config/docker.dev.env
APP_DEV_DOCKERCOMPOSE=docker-compose.dev.yml
APP_DOCKER_REPO=moodlenet/moodlenet
APP_DEV_CONTAINER="$(APP_NAME)_dev"
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
APP_BUILD ?= `git rev-parse --short HEAD`

init: 
	@echo "Running build scripts for $(APP_NAME):$(APP_VSN)-$(APP_BUILD)"

help: init
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build_without_cache: init ## Build the Docker image
	@echo docker build \
		--no-cache \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) .
	@docker build \
		--no-cache \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) .
	@echo $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD)

build: init ## Build the Docker image using previous cache
	@echo docker build \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) .
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
	@echo docker tag $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) $(APP_DOCKER_REPO):latest
	@docker tag $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD) $(APP_DOCKER_REPO):latest
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
	@curl https://team.moodle.net/devops/respawn/$(MAIL_KEY)
	@curl https://mothership.moodle.net/devops/respawn/$(MAIL_KEY)

hq_deploy_stable: init ## Used by Moodle HQ to trigger prod deploys to k8s
	@curl https://home.moodle.net/devops/respawn/$(MAIL_KEY)

dev-exports: init ## Load env vars from a dotenv file
	awk '{print "export " $$0}' $(APP_DEV_DOTENV)

dev-build: init ## Build the dev image
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) build web

dev-rebuild: init ## Rebuild the dev image (without cache)
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) build --no-cache web

dev-deps: init ## Prepare dev dependencies
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix local.hex --force
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix local.rebar --force
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix deps.get

dev-db-up: init ## Start the dev DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) up db

dev-db: init ## Create or reset the dev DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix ecto.reset

dev-db-migrate: init ## Run migrations on dev DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix ecto.migrate

dev-test-db: init ## Create or reset the test DB
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run -e MIX_ENV=test web mix ecto.reset

dev-test: init ## Run tests
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run web mix test

dev-psql: init ## Run postgres (without Docker)
	psql -h localhost -U postgres $(APP_DEV_CONTAINER)

dev-test-psql: init ## Run postgres for tests (without Docker)
	psql -h localhost -U postgres "$(APP_NAME)_test"

dev-setup: dev-deps dev-db ## Prepare dependencies and DB for dev

dev: init ## Run the app in dev 
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) run --service-ports web

dev-stop: init ## Stop the dev app
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) stop

dev-down: init ## Remove the dev app
	docker-compose -p $(APP_DEV_CONTAINER) -f $(APP_DEV_DOCKERCOMPOSE) down

manual-deps: init ## Prepare dependencies (without Docker)
	mix local.hex --force
	mix local.rebar --force
	mix deps.get

manual-db: init ## Create or reset the DB (without Docker)
	mix ecto.reset

good-tests: init
	mix test test/moodle_net/{access,activities,actors,collections,comments,common} \
                 test/moodle_net/{communities,localisation,meta,peers,resources,users} \
                 test/moodle_net_web/plugs/ \
                 test/moodle_net_web/graphql/{users,temporary}_test.exs \

run: init ## Run the app in Docker
	docker run\
		--env-file $(APP_DOTENV) \
		--expose 4000 -p 4000:4000 \
		--link db \
		--rm -it $(APP_DOCKER_REPO):$(APP_VSN)-$(APP_BUILD)
