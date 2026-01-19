all: setup

setup: kind.tmp istio-install istio-patch istio-injection deployment service virtualservice gateway

kind.tmp:
	kind create cluster --config kind-cluster-istio.yaml
	touch kind.tmp

deployment:
	kubectl apply -f http-echo-deployment.yaml

service:
	kubectl apply -f http-echo-service.yaml

virtualservice:
	kubectl apply -f http-echo-virtualservice.yaml

gateway:
	kubectl apply -f http-echo-gateway.yaml

istio-install:
	istioctl install -y

istio-patch:
	kubectl patch deployments.apps -n istio-system istio-ingressgateway -p '{"spec":{"template":{"spec":{"containers":[{"name":"istio-proxy","ports":[{"containerPort":8080,"hostPort":80},{"containerPort":8443,"hostPort":443}]}]}}}}'

istio-injection:
	kubectl label namespace default istio-injection=enabled

curl:
	curl http://localhost:80/

destroy:
	kind delete cluster
	rm kind.tmp
