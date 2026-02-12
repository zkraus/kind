
CERT_MANAGER_NAMESPACE=cert-manager
CERT_MANAGER_HELM_REPO=jetstack
CERT_MANAGER_HELM_REPO_URL=https://charts.jetstack.io
CERT_MANAGER_HELM_RELEASE=cert-manager

cert-manager: cert-manager-ns cert-manger-helm-repo cert-manager-install

cert-manager-ns:
	@kubectl get ns ${CERT_MANAGER_NAMESPACE} || \
	kubectl create namespace ${CERT_MANAGER_NAMESPACE}

cert-manager-helm-repo: cert-manager-ns
	@helm repo list | grep ${CERT_MANAGER_HELM_REPO} || \
	helm repo add ${CERT_MANAGER_HELM_REPO} ${CERT_MANAGER_HELM_REPO_URL} --force-update

cert-manager-install: cert-manager-ns cert-manager-helm-repo
	@helm list --namespace ${CERT_MANAGER_NAMESPACE} | grep ${CERT_MANAGER_HELM_RELEASE} || \
	( helm install ${CERT_MANAGER_HELM_RELEASE} jetstack/cert-manager --namespace ${CERT_MANAGER_NAMESPACE} --version v1.15.3 --set crds.enabled=true && \
	kubectl wait pod --all --for=condition=Ready -n $(CERT_MANAGER_NAMESPACE) --timeout 5m )


cert-manager-uninstall:
	@helm list --namespace ${CERT_MANAGER_NAMESPACE} | grep ${CERT_MANAGER_HELM_RELEASE} && \
	helm uninstall --namespace ${CERT_MANAGER_NAMESPACE} ${CERT_MANAGER_HELM_RELEASE} || true

cert-manager-destroy: cert-manager-uninstall
	@kubectl get ns ${CERT_MANAGER_NAMESPACE} && \
	kubectl delete ns ${CERT_MANAGER_NAMESPACE} || true

