KIND_CLUSTER_NAME ?= kind

ifeq (,$(wildcard ./kind-config.yaml))
KIND_CONF:=
else
KIND_CONF:=--config ./kind-config.yaml
endif


.DEFAULT_GOAL: all

.PHONY: all
all:



kind-start:
	@kind get clusters | grep $(KIND_CLUSTER_NAME) || \
		kind create cluster --name $(KIND_CLUSTER_NAME) $(KIND_CONF)



.PHONY: destroy
kind-destroy:
	kind delete cluster