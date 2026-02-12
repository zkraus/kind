.PHONY: all kind-start

include kind.mk

all: kind-start gateway-api deployment gateway 

gateway-api:
	kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.4.0" | kubectl apply -f -; }

# istio-install:
# 	istioctl install --set profile=minimal -y
# # 	kubectl label namespace default istio-injection=enabled

cert-manager: 
	kubectl get ns cert-manager || \
	( helm repo add jetstack https://charts.jetstack.io --force-update && \
	helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.15.3 --set crds.enabled=true )

kuadrant-install: cert-manager eg-gatewayclass gateway-api
	kubectl get ns kuadrant-system || \
	( helm repo add kuadrant https://kuadrant.io/helm-charts/ --force-update && \
	helm install kuadrant-operator kuadrant/kuadrant-operator --create-namespace --namespace kuadrant-system && \
	kubectl wait pod --all --for=condition=Ready -n kuadrant-system --timeout 5m )

kuadrant-resource: kuadrant-install
	kubectl apply -f kuadrant-resource.yaml
	kubectl -n kuadrant-system wait --for=condition=Ready kuadrant kuadrant

ratelimitpolicy: kuadrant-resource
	kubectl apply -f http-echo-ratelimit.yaml

envoy-install: metallb
	kubectl get ns envoy-gateway-system && \
	helm list -n envoy-gateway-system | grep eg || \
	helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.6.3 -n envoy-gateway-system --create-namespace && \
	kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available

envoy-patchpolicy-sync: envoy-install
	kubectl apply -f envoy-patchpolicy-configmap.yaml && \
	kubectl rollout restart deployment envoy-gateway -n envoy-gateway-system && \
	kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available


eg-gatewayclass: envoy-install
	kubectl apply -f eg-gatewayclass.yaml

# deployment + service
deployment:
	kubectl apply -f http-echo-deployment.yaml

# gateway + httproute
gateway: metallb envoy-install eg-gatewayclass
	kubectl apply -f http-echo-gateway.yaml

metallb:
	make -C ../add_metallb all

curl:
	curl -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/echo

while-curl:
	while :; do curl --write-out '%{http_code}\n' --silent --output /dev/null -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/echo | grep -E --color "\b(429)\b|$ " ; sleep 1 ; done

destroy: kind-stop

keycloak:
	kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.5.2/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
	kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.5.2/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
	kubectl create namespace keycloak
	kubectl -n keycloak apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.5.2/kubernetes/kubernetes.yml