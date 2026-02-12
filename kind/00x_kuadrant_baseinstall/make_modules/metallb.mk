
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

METALLB_NAMESPACE=metallb-system
METALLB_URL_MANIFEST=https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml

METALLB_LBPOOL_NAME=lb-pool

## VERY LIMITTED auto network range detection
KIND_NETWORK_ADDRESS=$(shell docker network inspect kind | jq '.[0].IPAM.Config.[].Subnet' | grep '\.' )
KIND_NETWORK_ADDRESS_PREFIX=$(shell echo ${KIND_NETWORK_ADDRESS}| sed -e 's/\.0\/16//' -e 's/"//g')

metallb-install:
	kubectl get namespace ${METALLB_NAMESPACE} || \
	( kubectl apply -f ${METALLB_URL_MANIFEST} && \
	kubectl wait pod --all --for=condition=Ready -n metallb-system --timeout 60s )

metallb-uninstall: metallb-address-pool-destroy
	kubectl get namespace ${METALLB_NAMESPACE} && \
	kubectl delete -f ${METALLB_URL_MANIFEST} || true

metallb-address-pool-check:
	echo ${KIND_NETWORK_ADDRESS}
	echo ${KIND_NETWORK_ADDRESS_PREFIX}

metallb-address-pool: metallb-address-pool-check metallb-install
	@kubectl -n ${METALLB_NAMESPACE} get IPAddressPool lb-pool || \
	sed 's/%NETWORK_ADDRESS_PREFIX%/${KIND_NETWORK_ADDRESS_PREFIX}/g' ${current_dir}/metallb-pool.yaml | kubectl apply -f -

metallb-address-pool-destroy:
	@kubectl -n ${METALLB_NAMESPACE} get IPAddressPool lb-pool && \
	sed 's/%NETWORK_ADDRESS_PREFIX%/${KIND_NETWORK_ADDRESS_PREFIX}/g' ${current_dir}/metallb-pool.yaml | kubectl delete -f - || true


metallb: metallb metallb-address-pool