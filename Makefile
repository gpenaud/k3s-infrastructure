SHELL := /bin/bash
ONESHELL:

# # ---------------------------------------------------------------------------- #
# # terraform
# # ---------------------------------------------------------------------------- #
#
# terraform-init:
# 	$(MAKE) -C terraform init
# terraform-up:
# 	$(MAKE) -C terraform up
# terraform-down:
# 	$(MAKE) -C terraform down
# terraform-apply:
# 	$(MAKE) -C terraform apply
# terraform-destroy:
# 	$(MAKE) -C terraform destroy
# terraform-provision:
# 	$(MAKE) -C terraform provision
# terraform-ssh:
# 	$(MAKE) -C terraform ssh

## start k3s
up-full:
	$(MAKE) up
	$(MAKE) import-cagette-image
	KUBECONFIG=/etc/rancher/k3s/k3s.yaml $(MAKE) install-prometheus
	KUBECONFIG=/etc/rancher/k3s/k3s.yaml $(MAKE) install-grafana
	# KUBECONFIG=/etc/rancher/k3s/k3s.yaml $(MAKE) install-cagette


## start k3s
up:
	$(MAKE) configure-iptables
	$(MAKE) install-k3s
	$(MAKE) chown-kubeconfig

## stop k3s
down:
	/usr/local/bin/k3s-uninstall.sh
	sudo rm -rf /mnt/k3s-data/*

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
	sudo wget -O /usr/local/bin/mkcert "https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64" ; chmod +x /usr/local/bin/mkcert
	mkcert -install

generate-certificates:
	mkcert -cert-file tls.raw.crt -key-file tls.raw.key grafana.localhost
	base64 tls.raw.crt > tls.base64.crt ; rm tls.raw.crt
	base64 tls.raw.key > tls.base64.key ; rm tls.raw.key

# ---------------------------------------------------------------------------- #
# cagette
# ---------------------------------------------------------------------------- #

## install prometheus
install-prometheus:
	KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install happy-lion helm/prometheus

## uninstall prometheus
uninstall-prometheus:
	KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm uninstall happy-lion

# ---------------------------------------------------------------------------- #
# grafana
# ---------------------------------------------------------------------------- #

## install grafana
install-grafana:
	KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install happy-tiger helm/grafana

## uninstall grafana
uninstall-grafana:
	KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm uninstall happy-tiger

# ---------------------------------------------------------------------------- #
# loki
# ---------------------------------------------------------------------------- #

## install grafana
install-loki:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm install happy-snake grafana/loki-stack --namespace logs --create-namespace

## uninstall loki
uninstall-loki:
	helm uninstall happy-snake

# ---------------------------------------------------------------------------- #
# cagette
# ---------------------------------------------------------------------------- #

## import local docker images
import-cagette-images:
	cd /home/gpenaud/work/ecolieu/cagette ; docker build -t cagette:1.0.0 . ; docker save --output cagette-1.0.0.tar cagette:1.0.0 ;\
	sudo k3s ctr images import cagette-1.0.0.tar ; rm -f cagette-1.0.0.tar
	cd /home/gpenaud/work/ecolieu/mailer ; docker build -t cagette-mailer:1.0.0 . ; docker save --output cagette-mailer-1.0.0.tar cagette-mailer:1.0.0 ; \
	sudo k3s ctr images import cagette-mailer-1.0.0.tar ; rm -f cagette-mailer-1.0.0.tar

## add cagette helm repository
add-cagette-helm-repository:
	helm repo add cagette "https://raw.githubusercontent.com/gpenaud/cagette/master/helm"

## install cagette
install-cagette:
	# helm repo add bitnami "https://charts.bitnami.com/bitnami"
	# helm dependency update /home/gpenaud/work/ecolieu/helm-cagette
	# helm dependency build /home/gpenaud/work/ecolieu/helm-cagette
	helm upgrade --install happy-dog /home/gpenaud/work/ecolieu/helm-cagette

## uninstall cagette
uninstall-cagette:
	helm uninstall happy-dog

# ---------------------------------------------------------------------------- #
# libairterre
# ---------------------------------------------------------------------------- #

## import local docker images
import-libairterre-image:
	cd /home/gpenaud/work/libairterre
	docker build -t libairterre:1.0.0 . ; docker save --output libairterre-1.0.0.tar libairterre:1.0.0
	sudo k3s ctr images import libairterre-1.0.0.tar ; rm -f libairterre-1.0.0.tar

## add libairterre helm repository
add-libairterre-helm-repository:
	helm repo add libairterre "https://raw.githubusercontent.com/gpenaud/libairterre/master/helm"

## install libairterre
install-libairterre:
	helm install happy-cat libairterre/libairterre-website

## uninstall libairterre
uninstall-libairterre:
	helm uninstall happy-cat
