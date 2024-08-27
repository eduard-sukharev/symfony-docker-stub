.DEFAULT_GOAL := default
default: start

include tools.mk

.PHONY: help
help::
	@echo "===========Makefile==========="
	@grep -hE '^[a-zA-Z_-]+:.*? ## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "=============================="

.PHONY: setup
setup: generate_certificates build up_d update_ca_certificates composer_install reset migrate ## Build docker images and install dependencies

.PHONY: start
start: up_d logs ## Start dev environment

.PHONY: restart
restart: up_d reset logs ## Restart dev environment and clear cache

.PHONY: build
build:
	docker compose build --force-rm ## Build docker images

.PHONY: up_d
up_d:
	docker compose up -d --force-recreate --remove-orphans

.PHONY: up
up:
	docker compose up --force-recreate --remove-orphans

.PHONY: composer_install
composer_install: ## Install composer dependencies
	docker compose exec -ti php composer install --optimize-autoloader --no-interaction

.PHONY: clear
clear: ## Clear Symfony cache
	docker compose exec -ti php php -d memory_limit=1024M -d xdebug.mode=off bin/console cache:clear

.PHONY: migrate
migrate:
	docker compose exec -ti php php bin/console doctrine:migrations:migrate --no-interaction

.PHONY: migration
migration:
	docker compose exec -ti php php bin/console doctrine:migrations:generate

.PHONY: down
down: ## Stop and delete containers
	docker compose down

.PHONY: logs
logs: ## Print latest logs
	docker compose logs

.PHONY: logsf
logsf: ## Watch logs live
	docker compose logs -f

.PHONY: stop
stop: ## Stop containers
	docker compose stop

.PHONY: generate_certificates
generate_certificates: install_certgen ## Generate certificates for local hosts
ifeq (,$(wildcard ./docker/nginx/private.key))
	./tools/certgen -host "project_name.test,localhost"
	mv -f private.key docker/nginx
	mv -f public.crt docker/nginx
endif
	echo "Certificates generated"

.PHONY: update_ca_certificates
update_ca_certificates:
	docker compose exec --user root -ti php update-ca-certificates
