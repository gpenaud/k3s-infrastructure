# Kubernetes (k3s)


### up / down k3s
```
make up
make down
```

Do not forget to export KUBECONFIG variable:
```
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

### install cagette

Add cagette repository
```
helm repo add cagette "https://raw.githubusercontent.com/gpenaud/cagette/helm/master/"
```

Install / uninstall cagette
```
helm install happy-poulette cagette/cagette-application
helm install happy-poulette cagette/cagette-application
```
