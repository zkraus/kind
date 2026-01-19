all: setup

setup: kind.tmp ingress-nginx deployment service ingress

kind.tmp:
	kind create cluster --config kind-cluster-ingress-nginx.yaml
	touch kind.tmp

deployment:
	kubectl apply -f http-echo-deployment.yaml

service:
	kubectl apply -f http-echo-service.yaml

ingress:
	kubectl apply -f http-echo-ingress.yaml

ingress-nginx:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl get pods -n ingress-nginx

wait-for-service-running:
	kubectl wait --for=jsonpath='{.status.availableReplicas}'>0 deployment/http-echo 

curl:
	curl http://localhost:80/

destroy:
	kind delete cluster
	rm kind.tmp
