.PHONY: all kind-start

rlp:
	kubectl apply -f http-echo-ratelimit.yaml

rlp-delete:
	kubectl delete -f http-echo-ratelimit.yaml

rlp-redo: rlp-delete rlp


# deployment + service
deployment:
	kubectl apply -f http-echo-deployment.yaml

# gateway + httproute
gateway: 
	kubectl apply -f http-echo-gateway.yaml

route: deployment gateway
	kubectl apply -f http-echo-httproute.yaml


setup: deployment gateway route
	kubectl wait --for=condition=Ready pod --all --timeout 120s
	kubectl get pod "$(shell kubectl get pods | grep 'http-echo-gateway' | cut -f 1 -d ' ')" -o json | jq ".spec.containers[].image"



clean:
	kubectl delete -f http-echo-httproute.yaml -f http-echo-gateway.yaml -f http-echo-deployment.yaml -f http-echo-ratelimit.yaml && \
	kubectl wait --for=condition=Deleted pods --all --timeout=30s || true

curl:
	curl -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/get

while-curl:
	while :; do date | tr '\n' '>'; curl --connect-timeout 1 --write-out '%{http_code}\n' --output /dev/null  --silent -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/get | grep -E --color "\b(429)\b|$ " ; sleep 0.5 ; done

logs:
	kubectl logs -p "$(shell kubectl get pods | grep 'http-echo-gateway' | cut -f 1 -d ' ')"


istio-version-126:
	make -C ../00x_kuadrant_baseinstall sail-operator-istio-objects ISTIO_OBJECT_VERSION=1.26.0
istio-version-127:
	make -C ../00x_kuadrant_baseinstall sail-operator-istio-objects ISTIO_OBJECT_VERSION=1.27.0
istio-version-128:
	make -C ../00x_kuadrant_baseinstall sail-operator-istio-objects ISTIO_OBJECT_VERSION=1.28.3

test: setup rlp while-curl

destroy: kind-stop
