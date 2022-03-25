.ONESHELL:

## permanent variables
PROJECT			?= github.com/gpenaud/k3s-infrastructure
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

## start k3s
up-full:
	$(MAKE) up
	$(MAKE) import-cagette-image
	$(MAKE) install-cagette
	$(MAKE) install-prometheus


## start k3s
up:
	$(MAKE) configure-iptables
	$(MAKE) install-k3s
	$(MAKE) chown-kubeconfig
	# $(MAKE) import-local-images

## stop k3s
down:
	/usr/local/bin/k3s-uninstall.sh

## configure and install k3s
configure-iptables:
	sudo iptables -I INPUT 3 -s 10.42.0.0/16 -j ACCEPT
	sudo iptables -I INPUT 3 -d 10.42.0.0/16 -j ACCEPT
	sudo iptables -I INPUT 3 -s 10.43.0.0/16 -j ACCEPT
	sudo iptables -I INPUT 3 -d 10.43.0.0/16 -j ACCEPT

## install k3s
install-k3s:
	curl -sfL https://get.k3s.io | sh -

## configure kubeconfig file
chown-kubeconfig:
	sudo chown gpenaud:gpenaud /etc/rancher/k3s/k3s.yaml

# ---------------------------------------------------------------------------- #
# certificate management
# ---------------------------------------------------------------------------- #

install-mkcert:
	sudo apt install --yes libnss3-tools
	sudo wget -O /usr/local/bin/mkcert "https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64" && chmod +x /usr/local/bin/mkcert
	mkcert -install

generate-certificates:
	mkcert -cert-file tls.raw.crt -key-file tls.raw.key prometheus.localhost
	base64 tls.raw.crt > tls.base64.crt && rm tls.raw.crt
	base64 tls.raw.key > tls.base64.key && rm tls.raw.key

# ---------------------------------------------------------------------------- #
# cagette
# ---------------------------------------------------------------------------- #

## install prometheus
install-prometheus:
	helm install happy-lion prometheus

## uninstall prometheus
uninstall-prometheus:
	helm uninstall happy-lion

# ---------------------------------------------------------------------------- #
# cagette
# ---------------------------------------------------------------------------- #

## import local docker images
import-cagette-image:
	cd /home/gpenaud/work/ecolieu/cagette
	docker build -t cagette:1.0.0 . && docker save --output cagette-1.0.0.tar cagette:1.0.0
	sudo k3s ctr images import cagette-1.0.0.tar && rm -f cagette-1.0.0.tar

## add cagette helm repository
add-cagette-helm-repository:
	helm repo add cagette "https://raw.githubusercontent.com/gpenaud/cagette/master/helm"

## install cagette
install-cagette:
	helm install happy-dog cagette/cagette-application

## uninstall cagette
uninstall-cagette:
	helm uninstall happy-dog

# ---------------------------------------------------------------------------- #
# libairterre
# ---------------------------------------------------------------------------- #

## import local docker images
import-libairterre-image:
	cd /home/gpenaud/work/libairterre
	docker build -t libairterre:1.0.0 . && docker save --output libairterre-1.0.0.tar libairterre:1.0.0
	sudo k3s ctr images import libairterre-1.0.0.tar && rm -f libairterre-1.0.0.tar

## add libairterre helm repository
add-libairterre-helm-repository:
	helm repo add libairterre "https://raw.githubusercontent.com/gpenaud/libairterre/master/helm"

## install libairterre
install-libairterre:
	helm install happy-cat libairterre/libairterre-website

## uninstall libairterre
uninstall-libairterre:
	helm uninstall happy-cat
