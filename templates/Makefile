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
export DEPLOY_STAGE := $(or $(word 2,$(MAKECMDGOALS)),development)

# if username not set we are in a drone environment
export USERNAME := $(or $(USERNAME), drone)
export EMAIL := $(or $(GIT_COMMITTER_EMAIL), $(shell git config user.email))

ifdef DRONE_REPO_BRANCH
	local_branch := $(DRONE_REPO_BRANCH)
else
	local_branch = $(shell git rev-parse --abbrev-ref HEAD | tr -d '\n')
endif

ifeq (, $(shell which mutagen-compose))
	COMPOSE_COMMAND = docker-compose
else
	ifdef DISABLE_MUTAGEN
		COMPOSE_COMMAND = docker-compose
	else ifeq (development, $(DEPLOY_STAGE))
		COMPOSE_COMMAND = mutagen-compose
		MUTAGEN_UP_TARGET = mutagen_up
		MUTAGEN_DOWN_TARGET = mutagen_down
	else
		COMPOSE_COMMAND = docker-compose
	endif
endif

ifeq (1, $(shell docker ps -a | grep traefik | wc -l ))
	SERVICE_TYPE := traefik
else ifeq (1, $(shell docker ps -a | grep influx | wc -l ))
	SERVICE_TYPE := influx
else 
	SERVICE_TYPE := portmap
endif

COMPOSE_FILES := ./compose/docker-compose.common.yml
COMPOSE_FILES += ./compose/docker-compose.proxy.${SERVICE_TYPE}.yml
COMPOSE_FILES += ./compose/docker-compose.$(DEPLOY_STAGE).yml

# check if rufus is set to be enabled 
ifeq (1, $(ENABLE_RUFUS_SCHEDULER))
	COMPOSE_FILES += ./compose/docker-compose.rufus.yml
endif

# get the app name from the current directory
export APP_NAME := $(notdir $(shell pwd))
export APP_DOMAIN := $(or $(shell hostname -d 2>/dev/null), rammount.com)
ifeq (development, $(DEPLOY_STAGE))
	export ATTACH_HOST 		:= app
	export APP_HOST_NAME 	:= $(APP_NAME).local
else
	export ATTACH_HOST 		:= app-green
	export APP_HOST_NAME 	:= $(APP_NAME)
endif

# use the rest as arguments as empty targets
EMPTY_TARGETS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(EMPTY_TARGETS):;@:)

up: build $(MUTAGEN_UP_TARGET)
	$(COMPOSE_COMMAND) $(FLAGS) up --force-recreate --abort-on-container-exit --remove-orphans

mutagen_up:
	-mutagen daemon start

mutagen_down:
	-mutagen daemon stop

down: compose_down $(MUTAGEN_DOWN_TARGET)

compose_down:
	$(COMPOSE_COMMAND) $(FLAGS) down

echo:
	@echo =========================================
	@echo = APP_NAME: $(APP_NAME)
	@echo = APP_DOMAIN: $(APP_DOMAIN)
	@echo = USERNAME: $(USERNAME)
	@echo = EMAIL: $(EMAIL)
	@echo = DEPLOY_STAGE: $(DEPLOY_STAGE)
	@echo = ATTACH_HOST: $(ATTACH_HOST)
	@echo = COMPOSE_COMMAND: $(COMPOSE_COMMAND)
	@echo = COMPOSE_FILES: $(COMPOSE_FILES)
	@echo = SERVICE_TYPE: $(SERVICE_TYPE)
	@echo =========================================

start: build 
	$(COMPOSE_COMMAND) $(FLAGS) up -d

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

init: FORCE docker-compose.yml .env 

FORCE:
	rm -f docker-compose.yml

docker-compose.yml: 
	cat ${COMPOSE_FILES} > docker-compose.yml

.env:
	@echo "RAILS_EMAIL_OVERRIDE=${EMAIL}" > .env
	cat .env.sample >> .env

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
