.PHONY: all kind-start

include kind.mk

all: kind-start gateway-api istio-install deployment gateway

gateway-api:
	kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.4.0" | kubectl apply -f -; }

istio-install:
	istioctl install --set profile=minimal -y
# 	kubectl label namespace default istio-injection=enabled


# deployment + service
deployment:
	kubectl apply -f http-echo-deployment.yaml

# gateway + httproute
gateway: metallb
	kubectl apply -f http-echo-gateway.yaml

metallb:
	make -C ../add_metallb all

curl:
	curl -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/echo

destroy: kind-stop
