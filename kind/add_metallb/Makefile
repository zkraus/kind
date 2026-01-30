.PHONY: all metallb kind-ready kind-running

KIND_CLUSTER_NAME ?= kind
KIND_CONF:=--config ./kind.yaml

all: metallb

kind-ready: kind-running
	kubectl wait --for jsonpath='{.status.phase}'=Active ns/default
	kubectl wait --for=create serviceaccount/default --timeout 60s

kind-running:
	kind get clusters | grep $(KIND_CLUSTER_NAME)

metallb: kind-ready
	docker network inspect kind | jq '.[0].IPAM.Config.[].Subnet'
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml
	kubectl wait pod --all --for=condition=Ready -n metallb-system --timeout 60s
	kubectl apply -f 02_metallb-pool.yaml
