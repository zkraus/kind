
TESTSUITE_NAMESPACE=kuadrant
TESTSUITE_NAMESPACE2=kuadrant2

testsuite-namespace: ns-kuadrant ns-kuadrant2

ns-kuadrant:
	@kubectl get ns ${TESTSUITE_NAMESPACE} || \
	( kubectl create namespace ${TESTSUITE_NAMESPACE} && \
	kubectl wait --for=create namespace/$(TESTSUITE_NAMESPACE) --timeout 60s )

ns-kuadrant2:
	@kubectl get ns ${TESTSUITE_NAMESPACE2} || \
	( kubectl create namespace ${TESTSUITE_NAMESPACE2} && \
	kubectl wait --for=create namespace/$(TESTSUITE_NAMESPACE2) --timeout 60s )


testsuite-namespace-destroy:
	@kubectl get ns ${TESTSUITE_NAMESPACE} && \
	kubectl delete namespace ${TESTSUITE_NAMESPACE} || true
	@kubectl get ns ${TESTSUITE_NAMESPACE2} && \
	kubectl delete namespace ${TESTSUITE_NAMESPACE2} || true
