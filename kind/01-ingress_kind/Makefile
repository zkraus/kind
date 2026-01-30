.PHONY: all kind-start deploy curl destroy

KIND_CLUSTER_NAME ?= kind
KIND_CONF:=--config ./kind.yaml

all: kind-ready

kind-start: 
	kind get clusters | grep $(KIND_CLUSTER_NAME) || \
		kind create cluster --name $(KIND_CLUSTER_NAME) $(KIND_CONF)

kind-ready: kind-running
	kubectl wait --for jsonpath='{.status.phase}'=Active ns/default
	kubectl wait --for=create serviceaccount/default --timeout 60s

kind-running: kind-start
	kind get clusters | grep $(KIND_CLUSTER_NAME)

kubect-get-all: kind-running
	kubectl get all

service:
	kubectl apply -f 02_service_nodeport.yaml
	kubectl get service

pod:
	kubectl apply -f 01_pods.yaml
	kubectl get pods

pod-delete:
	kubectl delete -f 01_pods.yaml

deployment:
	kubectl apply -f 03_deployment.yaml
	kubectl get deployment

kind-stop: 
	kind delete cluster --name $(KIND_CLUSTER_NAME) || \
		echo "kind cluster is not running"

# deploy: kind-ready
# 	kubectl apply -f ingress-kind-example.yaml
# 	kubectl wait --for jsonpath='{.status.phase}'=Running pod/echopod-app

curl:
	curl http://127.0.0.1:80/

destroy: kind-stop


kind-load:
	kind load docker-image das_app:0.1.0

das_app_deploy: kind-load
	kubectl delete deployment http-echo || true
	kubectl apply -f 04_das_app_deployment.yaml
	kubect get all
