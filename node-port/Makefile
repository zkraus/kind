all: setup

setup: kind.tmp deployment service


kind.tmp:
	kind create cluster --config kind-cluster-node-port.yaml
	touch kind.tmp

deployment:
	kubectl apply -f http-echo-deployment.yaml

service:
	kubectl apply -f http-echo-service.yaml

wait-for-service-running:
	kubectl wait --for=jsonpath='{.status.availableReplicas}'>0 deployment/http-echo 

curl:
	curl http://localhost:80/

destroy:
	kind delete cluster
	rm kind.tmp
