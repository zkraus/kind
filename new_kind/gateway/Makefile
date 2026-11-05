.PHONY: all kind-start

all: gateway-api istio-install

gateway-api: kind-start
	kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.4.0" | kubectl apply -f -; }

istio-install: gateway-api
	istioctl install --set profile=default -y


## DO NOT FORGET LOADBALANCER WITH cloud-provider-kind
cloud-provider:
	cloud-provider-kind --enable-lb-port-mapping


route:
	kubectl apply -f http-echo-gateway.yaml
	kubectl apply -f http-echo-httproute.yaml