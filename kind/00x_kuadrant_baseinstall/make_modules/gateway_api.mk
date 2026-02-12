
gateway-api: kind-start
	@kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.4.0" | kubectl apply -f -; }

gateway-api-destroy:
	@kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null && \
	{ kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.4.0" | kubectl delete -f -; } || true