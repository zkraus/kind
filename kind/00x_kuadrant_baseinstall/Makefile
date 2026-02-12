.PHONY: all destroy

include make_modules/kubectl.mk
include make_modules/kind.mk
include make_modules/gateway_api.mk
include make_modules/cert_manager.mk

include make_modules/metallb.mk

include make_modules/istio.mk

include make_modules/keycloak.mk

include make_modules/kuadrant.mk

include make_modules/testsuite.mk

.DEFAULT_GOAL := all

all: kind-start



destroy: kind-stop