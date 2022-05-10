init:
	terraform -chdir=layers/storage init
	terraform -chdir=modules/container init
	terraform init

apply:
	terraform -chdir=layers/storage apply -auto-approve
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve
	terraform -chdir=layers/storage destroy -auto-approve

up: apply provision
down: destroy

provision:
	@cd ansible
	@ansible-playbook --inventory inventory playbooks/provision.yaml

ssh:
	@ssh ubuntu@controlplane-01.k8s

up-full: down up provision ssh


.ONESHELL:

## permanent variables
PROJECT			?= github.com/gpenaud/poc-lxc-terraform
RELEASE			?= $(shell git describe --tags --abbrev=0)
COMMIT			?= $(shell git rev-parse --short HEAD)
BUILD_TIME  ?= $(shell date -u '+%Y-%m-%d_%H:%M:%S')

## Colors
COLOR_RESET       = $(shell tput sgr0)
COLOR_ERROR       = $(shell tput setaf 1)
COLOR_COMMENT     = $(shell tput setaf 3)
COLOR_TITLE_BLOCK = $(shell tput setab 4)

## display this help text
help:
	@printf "\n"
	@printf "${COLOR_TITLE_BLOCK}${PROJECT} Makefile${COLOR_RESET}\n"
	@printf "\n"
	@printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	@printf " make build\n\n"
	@printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	@awk '/^[a-zA-Z\-_0-9@]+:/ { \
				helpLine = match(lastLine, /^## (.*)/); \
				helpCommand = substr($$1, 0, index($$1, ":")); \
				helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
				printf " ${COLOR_INFO}%-15s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
		{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@printf "\n"
