.PHONY: all setup kind gateway-api istio-install deployment ingress-traffic http-route

include kind.mk

.DEFAULT_GOAL: help

all: setup




setup: kind-start gateway-api istio-install deployment ingress-traffic http-route

gateway-api:
	kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.4.0" | kubectl apply -f -; }

istio-install:
	istioctl install --set profile=minimal -y

deployment:
	kubectl create ns sample
	kubectl apply -f helloworld.yaml -n sample
	kubectl get pod -n sample

ingress-traffic:
	kubectl create namespace sample-ingress
	kubectl apply -f sample-gateway.yaml
	kubectl wait -n sample-ingress --for=condition=programmed gateway sample-gateway
	kubectl get -n sample-ingress gateway sample-gateway -o jsonpath='{.status.addresses[0].value}'

http-route:
	kubectl apply -n sample -f http-route.yaml

curl:
	ADDRESS:=$(shell kubectl get -n sample-ingress gateway sample-gateway -o jsonpath='{.status.addresses[0].value}')
	curl -hHost=helloworld.sample.com http://$(ADDRESS):80/hello

destroy: kind-stop
