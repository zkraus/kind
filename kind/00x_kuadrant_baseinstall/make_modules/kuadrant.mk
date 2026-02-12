
KUADRANT_NAMESPACE=kuadrant-system

KUADRANT_HELM_RELEASE=kuadrant-operator
KUADRANT_HELM_REPO=kuadrant
KUADRANT_HELM_URL=https://kuadrant.io/helm-charts/


mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

kuadrant-namespace:
	@kubectl get ns ${KUADRANT_NAMESPACE} || \
	kubectl create ns ${KUADRANT_NAMESPACE}


kuadrant-helm-repo: 
	@helm repo list | grep ${KUADRANT_HELM_REPO} || \
	helm repo add ${KUADRANT_HELM_REPO} ${KUADRANT_HELM_URL} --force-update

kuadrant-install: gateway-api metallb istio cert-manager keycloak kuadrant-namespace kuadrant-helm-repo
	@helm list --namespace ${KUADRANT_NAMESPACE} | grep ${KUADRANT_HELM_RELEASE} || \
	( helm install ${KUADRANT_HELM_RELEASE} kuadrant/kuadrant-operator --namespace ${KUADRANT_NAMESPACE} && \
	kubectl wait pod --all --for=condition=Ready -n ${KUADRANT_NAMESPACE} --timeout 5m )

kuadrant-resource: kuadrant-install
	@kubectl -n ${KUADRANT_NAMESPACE} get Kuadrant/kuadrant || \
	( kubectl apply -f ${current_dir}/kuadrant-resource.yaml && \
	kubectl -n ${KUADRANT_NAMESPACE} wait --for=condition=Ready kuadrant kuadrant )

kuadrant-resource-destroy:
	@kubectl -n ${KUADRANT_NAMESPACE} get Kuadrant/kuadrant && \
	kubectl delete -f ${current_dir}/kuadrant-resource.yaml || true

kuadrant-uninstall: kuadrant-resource-destroy
	@helm list --namespace ${KUADRANT_NAMESPACE} | grep ${KUADRANT_HELM_RELEASE} && \
	helm uninstall --namespace ${KUADRANT_NAMESPACE} ${KUADRANT_HELM_RELEASE} || true


kuadrant: kuadrant-install kuadrant-resource
