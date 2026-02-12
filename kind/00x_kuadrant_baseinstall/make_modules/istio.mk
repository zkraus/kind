

ISTIO_NAMESPACE=istio-system

SAIL_HELM_REPO=sail-operator
SAIL_HELM_URL=https://istio-ecosystem.github.io/sail-operator
SAIL_HELM_RELEASE=sail-operator


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

istio-sail-operator-install: istio-version-check istio-namespace sail-operator-helm-repo sail-operator-install

sail-operator-helm-repo:
	@helm repo list | grep ${SAIL_HELM_REPO} || \
	helm repo add ${SAIL_HELM_REPO} ${SAIL_HELM_URL} --force-update

sail-operator-install: istio-namespace sail-operator-helm-repo
	@helm list --namespace ${ISTIO_NAMESPACE} | grep ${SAIL_HELM_RELEASE} || \
	( helm install ${SAIL_HELM_RELEASE} \
		--namespace ${ISTIO_NAMESPACE} \
		--wait \
		--timeout=300s \
		sail-operator/sail-operator \
		--version ${ISTIO_VERSION} && \
		sed 's/%ISTIO_VERSION%/${ISTIO_OBJECT_VERSION}/' ${current_dir}/istio-objects.yaml | kubectl apply -f - )

sail-operator-uninstall:
	@helm list --namespace ${ISTIO_NAMESPACE} | grep ${SAIL_HELM_RELEASE} && \
	helm uninstall --namespace ${ISTIO_NAMESPACE} ${SAIL_HELM_RELEASE} || true

istio-namespace:
	@kubectl get ns ${ISTIO_NAMESPACE} || \
	kubectl create namespace ${ISTIO_NAMESPACE}


istio: istio-sail-operator-install