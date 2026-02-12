.PHONY: all kind-start

include kind.mk

all: kind-start gateway-api istio-install deployment gateway kuadrant keycloak testsuite-namespace

gateway-api: kind-start
	kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.4.0" | kubectl apply -f -; }

istio-install: gateway-api
	istioctl install --set profile=minimal -y
# 	kubectl label namespace default istio-injection=enabled







cert-manager: 
	kubectl get ns cert-manager || \
	( helm repo add jetstack https://charts.jetstack.io --force-update && \
	helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.15.3 --set crds.enabled=true )

kuadrant-install: cert-manager istio-install gateway-api
	kubectl get ns kuadrant-system || \
	( helm repo add kuadrant https://kuadrant.io/helm-charts/ --force-update && \
	helm install kuadrant-operator kuadrant/kuadrant-operator --create-namespace --namespace kuadrant-system && \
	kubectl wait pod --all --for=condition=Ready -n kuadrant-system --timeout 5m )

testsuite-namespace:
	kubectl create namespace kuadrant

kuadrant: kuadrant-install
	kubectl apply -f kuadrant-resource.yaml
	kubectl -n kuadrant-system wait --for=condition=Ready kuadrant kuadrant

ratelimitpolicy: kuadrant
	kubectl apply -f http-echo-ratelimit.yaml

# deployment + service
deployment:
	kubectl apply -f http-echo-deployment.yaml

# gateway + httproute
gateway: metallb
	kubectl apply -f http-echo-gateway.yaml

route: deployment gateway
	kubectl apply -f http-echo-httproute.yaml

metallb: kind-start
	make -C ../add_metallb all

curl:
	curl -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/get

while-curl:
	while :; do date | tr '\n' '>'; curl --connect-timeout 1 --write-out '%{http_code}\n' --output /dev/null  --silent -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/get | grep -E --color "\b(429)\b|$ " ; sleep 0.5 ; done


destroy: kind-stop

keycloak:
	kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.5.2/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
	kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.5.2/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
	kubectl create namespace keycloak
	kubectl -n keycloak apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.5.2/kubernetes/kubernetes.yml
