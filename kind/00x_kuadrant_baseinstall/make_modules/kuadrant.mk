
KUADRANT_NAMESPACE=kuadrant-system

KUADRANT_HELM_RELEASE=kuadrant-operator
KUADRANT_HELM_REPO=kuadrant
KUADRANT_HELM_URL=https://kuadrant.io/helm-charts/

kuadrant-namespace:
	@kubectl get ns ${KUADRANT_NAMESPACE} || \
	kubectl create ns {KEYCLOAK_NAMESPACE}





kuadrant-install: cert-manager istio-install gateway-api
	kubectl get ns kuadrant-system || \
	( helm repo add kuadrant https://kuadrant.io/helm-charts/ --force-update && \
	helm install kuadrant-operator kuadrant/kuadrant-operator --create-namespace --namespace kuadrant-system && \
	kubectl wait pod --all --for=condition=Ready -n kuadrant-system --timeout 5m )

