
KEYCLOAK_NAMESPACE=keycloak


KEYCLOAK_URL_KEYCLOAKS=https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.5.2/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
KEYCLOAK_URL_REALIMPORTS=https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.5.2/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
KEYCLOAK_URL_RESOURCES=https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.5.2/kubernetes/kubernetes.yml

keycloak-namespace:
	@kubectl get ns ${KEYCLOAK_NAMESPACE} || \
	kubectl create namespace ${KEYCLOAK_NAMESPACE}

keycloak-namespace-delete:
	@kubectl get ns ${KEYCLOAK_NAMESPACE} && \
	kubectl delete namespace ${KEYCLOAK_NAMESPACE} || true


keycloak-keycloaks-install:
	kubectl apply -f ${KEYCLOAK_URL_KEYCLOAKS}

keycloak-keycloaks-uninstall:
	kubectl delete -f ${KEYCLOAK_URL_KEYCLOAKS}


keycloak-realimports-install:
	kubectl apply -f  ${KEYCLOAK_URL_REALIMPORTS}

keycloak-realimports-uninstall:
	kubectl delete -f  ${KEYCLOAK_URL_REALIMPORTS}



keycloak-resource-install:
	kubectl -n keycloak apply -f ${KEYCLOAK_URL_RESOURCES}

keycloak-resource-uninstall:
	kubectl -n keycloak delete -f ${KEYCLOAK_URL_RESOURCES}


keycloak-install: keycloak-namespace keycloak-keycloaks-install keycloak-realimports-install keycloak-resource-install

keycloak-uninstall:	keycloak-resource-uninstall keycloak-realimports-uninstall keycloak-keycloaks-uninstall keycloak-namespace-delete  

