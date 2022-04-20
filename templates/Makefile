# lets try the new docker build system
# https://docs.docker.com/develop/develop-images/build_enhancements/
# https://www.docker.com/blog/faster-builds-in-compose-thanks-to-buildkit-support/
export DOCKER_BUILDKIT := 1
export DOCKER_SCAN_SUGGEST := false
export COMPOSE_DOCKER_CLI_BUILD := 1
export BUILDKIT_PROGRESS=plain

# include .env if present
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# get current timestamp
export DATE := $(shell date '+%Y-%m-%d-%H.%M.%S')
export PUID := $(shell id -u)
export PGID := $(shell id -g)

# if username not set we are in a drone environment
export USERNAME := $(or $(USERNAME), drone)

#export EMAIL := $(or $(GIT_COMMITTER_EMAIL), $(shell git config user.email))
export EMAIL := $(or $(GIT_COMMITTER_EMAIL), $(shell git config user.email))

ifdef DRONE_REPO_BRANCH
	local_branch := $(DRONE_REPO_BRANCH)
else
	local_branch = $(shell git rev-parse --abbrev-ref HEAD | tr -d '\n')
endif

ifeq (master,$(local_branch))
	ENV_CONTEXT := production
else
	ENV_CONTEXT := $(local_branch)
endif

# If the first argument is "deploy"...
ifeq (deploy,$(firstword $(MAKECMDGOALS)))
	ENV_CONTEXT := production
	PASSED_COMMAND := $(word 2,$(MAKECMDGOALS))
	DEPLOY_STAGE := $(or $(PASSED_COMMAND),$(ENV_CONTEXT))
# If the first argument is "test"...
else ifeq (test,$(firstword $(MAKECMDGOALS)))
	# default DEPLOY_STAGE & ENV_CONTEXT to test
	ENV_CONTEXT := $(or $(word 2,$(MAKECMDGOALS)),test)
	DEPLOY_STAGE := $(or $(word 2,$(MAKECMDGOALS)),test)
else
	# default DEPLOY_STAGE to development
	ENV_CONTEXT := $(or $(word 2,$(MAKECMDGOALS)),development)
	DEPLOY_STAGE := $(or $(word 2,$(MAKECMDGOALS)),development)
endif
export DEPLOY_STAGE
export ENV_CONTEXT


ifeq (, $(shell which mutagen-compose))
	COMPOSE_COMMAND = docker-compose
else 
	ifeq (development, $(ENV_CONTEXT))
		COMPOSE_COMMAND = mutagen-compose
	else
		COMPOSE_COMMAND = docker-compose
	endif
endif

# set the $(COMPOSE_COMMAND) FLAGS based on the DEPLOY_STAGE value
FLAGS = 

ifneq (,$(wildcard ./docker-compose.$(DEPLOY_STAGE).yml))
  FLAGS += -f ./docker-compose.$(DEPLOY_STAGE).yml
endif

TRAEFIK := $(shell docker ps -a | grep traefik | wc -l )
INFLUX := $(shell docker ps -a | grep influx | wc -l )

ifeq (1, $(TRAEFIK))
	FLAGS += -f ./docker-compose.traefik.$(ENV_CONTEXT).yml
else ifeq (1, $(INFLUX))
	FLAGS += -f ./docker-compose.influx.$(ENV_CONTEXT).yml
else ifeq (development,$(DEPLOY_STAGE))
	FLAGS += -f ./docker-compose.portmap.yml
endif

# check if rufus is set to be enabled 
ifeq (1, $(ENABLE_RUFUS_SCHEDULER))
	FLAGS += -f ./docker-compose.rufus.yml
endif

# determine the name of the first service in the docker-compose.yml
ifeq (development, $(DEPLOY_STAGE))
	export ATTACH_HOST := app
else
	export ATTACH_HOST := app-green
endif
# get the app name from the current directory
export APP_NAME := $(notdir $(shell pwd))
export APP_DOMAIN := $(or $(shell hostname -d 2>/dev/null), rammount.com)

# use the rest as arguments as empty targets
EMPTY_TARGETS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(EMPTY_TARGETS):;@:)

up: build
	$(COMPOSE_COMMAND) $(FLAGS) up --force-recreate --abort-on-container-exit --remove-orphans

echo:
	@echo =========================================
	@echo = APP_NAME: $(APP_NAME)
	@echo = APP_DOMAIN: $(APP_DOMAIN)
	@echo = USERNAME: $(USERNAME)
	@echo = EMAIL: $(EMAIL)
	@echo = ENV_CONTEXT:  $(ENV_CONTEXT)
	@echo = DEPLOY_STAGE: $(DEPLOY_STAGE)
	@echo = ATTACH_HOST: $(ATTACH_HOST)
	@echo = COMPOSE_COMMAND: $(COMPOSE_COMMAND)
	@echo = FLAGS: $(FLAGS)
	@echo = TRAEFIK: $(TRAEFIK)
	@echo = INFLUX: $(INFLUX)
	@echo =========================================

start: build 
	$(COMPOSE_COMMAND) $(FLAGS) up -d

down: detach
	$(COMPOSE_COMMAND) $(FLAGS) down

restart: down 

test: build
	$(COMPOSE_COMMAND) $(FLAGS) run --rm $(ATTACH_HOST) bundle exec rspec

bash: build
	$(COMPOSE_COMMAND) $(FLAGS) run --rm $(ATTACH_HOST) bash -l

# for bundle updates and other commands that may need root access to the container
bundle: build 
	$(COMPOSE_COMMAND) -f $(COMPOSE_COMMAND).yml -f $(COMPOSE_COMMAND).bundle.yml run --rm $(ATTACH_HOST) bash -l

build: init
	@-rm -f tmp/pids/*.pid # - ignore errors
	$(COMPOSE_COMMAND) $(FLAGS) build 

env: 
	env | sort

init: .env base/Gemfile.lock

.env:
	@echo "RAILS_EMAIL_OVERRIDE=${EMAIL}" > .env
	cat env.sample >> .env

base/Gemfile.lock:
	@touch base/Gemfile.lock

logs:
	$(COMPOSE_COMMAND)  $(FLAGS) logs -f

tag:
	git -c user.email=${EMAIL} -c user.name='${USER}' tag -a "${RAILS_ENV}-$(DATE)" -m "deployed to ${RAILS_ENV} by ${USER}"
	git -c user.email=${EMAIL} -c user.name='${USER}' push --follow-tags

update: build	
	@echo "restarting service_blue container..."
	-$(COMPOSE_COMMAND) $(FLAGS) stop --timeout 30 service_blue
	$(COMPOSE_COMMAND) $(FLAGS) up -d --force-recreate service_blue

	sleep 10
	
	@echo "restarting service_green container..."
	-$(COMPOSE_COMMAND) $(FLAGS) stop --timeout 30 service_green
	$(COMPOSE_COMMAND) $(FLAGS) up -d --force-recreate service_green

newrelic-mark:
	@echo Creating New Relic Deployment marker
	$(COMPOSE_COMMAND) $(FLAGS) exec -T $(ATTACH_HOST) ${COMMAND}
