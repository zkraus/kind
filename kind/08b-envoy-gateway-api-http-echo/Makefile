.PHONY: all kind-start

include kind.mk

all: kind-start gateway-api deployment gateway

gateway-api:
	kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.4.0" | kubectl apply -f -; }

# istio-install:
# 	istioctl install --set profile=minimal -y
# # 	kubectl label namespace default istio-injection=enabled

envoy-install: metallb
	kubectl get ns envoy-gateway-system && \
	helm list -n envoy-gateway-system | grep eg || \
	helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.6.3 -n envoy-gateway-system --create-namespace && \
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

destroy: kind-stop
