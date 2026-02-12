

ISTIO_NAMESPACE=istio-system

SAIL_HELM_REPO=sail-operator
SAIL_HELM_URL=https://istio-ecosystem.github.io/sail-operator
SAIL_HELM_RELEASE=sail-operator
ISTIOD_HELM_RELEASE=default-istiod


# istio version supplied to operator when installing
ISTIO_VERSION=1.26.0

# Istio object in kubernetes
ISTIO_OBJECT_VERSION=${ISTIO_VERSION}


mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))


istioctl-version:
	istioctl version

istio-version-check:
	@echo ISTIO_VERSION=${ISTIO_VERSION}
	@echo ISTIO_OBJECT_VERSION=${ISTIO_OBJECT_VERSION}

istio-istioctl-install:
	istioctl install --set profile=minimal -y

istio-sail-operator-install: istio-version-check istio-namespace sail-operator-helm-repo sail-operator-install sail-operator-istio-objects
istio-sail-operator-uninstall: sail-operator-istio-objects-uninstall sail-operator-uninstall istio-namespace-destroy

sail-operator-helm-repo:
	@helm repo list | grep ${SAIL_HELM_REPO} || \
	helm repo add ${SAIL_HELM_REPO} ${SAIL_HELM_URL} --force-update

sail-operator-install: istio-namespace sail-operator-helm-repo
	@helm list --namespace ${ISTIO_NAMESPACE} | grep ${SAIL_HELM_RELEASE} || \
	helm install ${SAIL_HELM_RELEASE} \
		--namespace ${ISTIO_NAMESPACE} \
		--wait \
		--timeout=300s \
		sail-operator/sail-operator \
		--version ${ISTIO_VERSION}

sail-operator-istio-objects: sail-operator-install
	@helm list --namespace ${ISTIO_NAMESPACE} | grep ${SAIL_HELM_RELEASE} && \
	sed 's/%ISTIO_VERSION%/${ISTIO_OBJECT_VERSION}/' ${current_dir}/istio-objects.yaml | kubectl apply -f -

sail-operator-istio-objects-uninstall:
	sed 's/%ISTIO_VERSION%/${ISTIO_OBJECT_VERSION}/' ${current_dir}/istio-objects.yaml | kubectl delete -f - || true

sail-operator-uninstall:
	@helm list --namespace ${ISTIO_NAMESPACE} | grep ${SAIL_HELM_RELEASE} && \
	helm uninstall --namespace ${ISTIO_NAMESPACE} ${SAIL_HELM_RELEASE} || true 
	@helm list --namespace ${ISTIO_NAMESPACE} | grep ${ISTIOD_HELM_RELEASE} && \
	helm uninstall --namespace ${ISTIO_NAMESPACE} ${ISTIOD_HELM_RELEASE} || true 


istio-namespace:
	@kubectl get ns ${ISTIO_NAMESPACE} || \
	kubectl create namespace ${ISTIO_NAMESPACE}

istio-namespace-destroy:
	@kubectl get ns ${ISTIO_NAMESPACE} && \
	kubectl delete namespace ${ISTIO_NAMESPACE} || true

istio: istio-sail-operator-install
istio-uninstall: istio-sail-operator-uninstall