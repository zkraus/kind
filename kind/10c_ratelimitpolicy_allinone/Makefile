.PHONY: all 

all: deploy while-curl 

deploy:
	kubectl apply -f allinone.yaml
	kubectl get all
	kubectl get gateway/http-echo-gateway
	kubectl get httproute/http-echo
	kubectl get ratelimitpolicy/gw-rlp

curl:
	curl -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/echo

while-curl:
	while :; do exec "curl --connect-timeout 1 --write-out '%{http_code}\n' --silent --output /dev/null -HHost:try.echo.com http://$(shell kubectl get gateway http-echo-gateway -o jsonpath='{.status.addresses[0].value}'):80/echo | grep -E --color \"\b(429)\b|$ \""' ; sleep 0.5 ; done

clean:
	kubectl delete -f allinone.yaml

