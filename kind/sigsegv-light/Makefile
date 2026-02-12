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



clean:
	kubectl delete -f http-echo-httproute.yaml -f http-echo-gateway.yaml -f http-echo-deployment.yaml -f http-echo-ratelimit.yaml

curl:
	curl -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/get

while-curl:
	while :; do date | tr '\n' '>'; curl --connect-timeout 1 --write-out '%{http_code}\n' --output /dev/null  --silent -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/get | grep -E --color "\b(429)\b|$ " ; sleep 0.5 ; done


destroy: kind-stop