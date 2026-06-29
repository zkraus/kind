"""
DasApp Kubernetes Operator using Kopf framework.

This operator watches for DasApp custom resources and:
1. Creates a Deployment with das_app containers
2. Creates a Service to expose the app
3. Monitors health and updates status

Learn more about Kopf: https://kopf.readthedocs.io/
"""

import kopf
import kubernetes
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@kopf.on.create('dasapp.example.com', 'v1', 'dasapps')
def create_fn(spec, name, namespace, logger, **kwargs):
    """
    Called when a DasApp resource is created.

    Args:
        spec: The .spec section from the DasApp YAML
        name: Name of the DasApp resource
        namespace: Namespace where DasApp was created
        logger: Logger instance for this handler
        **kwargs: Other metadata Kopf provides (status, meta, etc.)

    This function creates:
    1. A Deployment to run das_app pods
    2. A Service to expose the pods
    """
    logger.info(f"Creating DasApp: {name} in namespace {namespace}")

    # Extract configuration from spec (with defaults)
    replicas = spec.get('replicas', 1)
    label = spec.get('label', 'Das APP')
    image = spec.get('image', 'das_app:latest')
    port = spec.get('port', 8080)
    service_type = spec.get('serviceType', 'ClusterIP')

    # Get Kubernetes API clients
    apps_v1 = kubernetes.client.AppsV1Api()
    core_v1 = kubernetes.client.CoreV1Api()

    # Create Deployment
    deployment = create_deployment(name, namespace, replicas, label, image, port)
    apps_v1.create_namespaced_deployment(namespace=namespace, body=deployment)
    logger.info(f"Created Deployment: {name}")

    # Create Service
    service = create_service(name, namespace, port, service_type)
    core_v1.create_namespaced_service(namespace=namespace, body=service)
    logger.info(f"Created Service: {name}")

    # Return status update - Kopf will write this to .status
    return {'ready': False, 'healthyReplicas': 0}


@kopf.on.update('dasapp.example.com', 'v1', 'dasapps')
def update_fn(spec, name, namespace, old, new, diff, logger, **kwargs):
    """
    Called when a DasApp resource is updated.

    Args:
        old: Previous spec
        new: New spec
        diff: List of changes (field, old_value, new_value)

    This reconciles the Deployment and Service to match new spec.
    """
    logger.info(f"Updating DasApp: {name}, changes: {diff}")

    # Get Kubernetes API clients
    apps_v1 = kubernetes.client.AppsV1Api()
    core_v1 = kubernetes.client.CoreV1Api()

    # Extract new configuration
    replicas = spec.get('replicas', 1)
    label = spec.get('label', 'Das APP')
    image = spec.get('image', 'das_app:latest')
    port = spec.get('port', 8080)
    service_type = spec.get('serviceType', 'ClusterIP')

    # Update Deployment
    deployment = create_deployment(name, namespace, replicas, label, image, port)
    apps_v1.patch_namespaced_deployment(
        name=name,
        namespace=namespace,
        body=deployment
    )
    logger.info(f"Updated Deployment: {name}")

    # Update Service
    service = create_service(name, namespace, port, service_type)
    core_v1.patch_namespaced_service(
        name=name,
        namespace=namespace,
        body=service
    )
    logger.info(f"Updated Service: {name}")


@kopf.on.delete('dasapp.example.com', 'v1', 'dasapps')
def delete_fn(spec, name, namespace, logger, **kwargs):
    """
    Called when a DasApp resource is deleted.

    Kubernetes automatically deletes child resources (Deployment, Service)
    because we set ownerReferences (see create_deployment/create_service).
    This is called "garbage collection".

    We just log the deletion here.
    """
    logger.info(f"Deleting DasApp: {name} in namespace {namespace}")
    # Kubernetes will clean up Deployment and Service automatically


@kopf.timer('dasapp.example.com', 'v1', 'dasapps', interval=30.0)
def health_check(spec, name, namespace, status, logger, patch, **kwargs):
    """
    Called every 30 seconds for each DasApp (timer handler).

    This checks pod health and updates .status with current state.

    Args:
        status: Current .status from the DasApp
        patch: Object to update DasApp fields (patch.status['key'] = value)
    """
    logger.info(f"Health check for DasApp: {name}")

    # Get Kubernetes API client
    core_v1 = kubernetes.client.CoreV1Api()

    try:
        # Find pods matching our deployment's labels
        pods = core_v1.list_namespaced_pod(
            namespace=namespace,
            label_selector=f"app={name}"
        )

        # Count how many pods are ready
        healthy_count = 0
        for pod in pods.items:
            # Check pod status
            if pod.status.phase == "Running":
                # Check all containers in pod are ready
                if pod.status.container_statuses:
                    all_ready = all(cs.ready for cs in pod.status.container_statuses)
                    if all_ready:
                        healthy_count += 1

        total_pods = len(pods.items)
        desired_replicas = spec.get('replicas', 1)

        # App is "ready" when healthy pods == desired replicas
        is_ready = (healthy_count == desired_replicas and healthy_count > 0)

        logger.info(f"Health: {healthy_count}/{total_pods} pods ready (want {desired_replicas})")

        # Update status (Kopf will write this to .status in Kubernetes)
        patch.status['ready'] = is_ready
        patch.status['healthyReplicas'] = healthy_count
        patch.status['lastHealthCheck'] = kubernetes.client.V1ObjectMeta().to_dict().get('creation_timestamp')

    except Exception as e:
        logger.error(f"Health check failed: {e}")
        patch.status['ready'] = False


def create_deployment(name, namespace, replicas, label, image, port):
    """
    Creates a Deployment spec for das_app.

    A Deployment manages a ReplicaSet which manages Pods.
    We define what containers to run and how many replicas.
    """
    return {
        'apiVersion': 'apps/v1',
        'kind': 'Deployment',
        'metadata': {
            'name': name,
            'namespace': namespace,
            # ownerReferences links this Deployment to the DasApp resource
            # When DasApp is deleted, Kubernetes auto-deletes this Deployment
            'ownerReferences': [{
                'apiVersion': 'dasapp.example.com/v1',
                'kind': 'DasApp',
                'name': name,
                'uid': 'placeholder',  # Kopf will fill this automatically
                'controller': True,
                'blockOwnerDeletion': True,
            }],
        },
        'spec': {
            'replicas': replicas,
            # Selector tells Deployment which pods it manages
            'selector': {
                'matchLabels': {'app': name}
            },
            # Template defines the pod spec
            'template': {
                'metadata': {
                    'labels': {'app': name}
                },
                'spec': {
                    'containers': [{
                        'name': 'das-app',
                        'image': image,
                        'ports': [{'containerPort': port}],
                        # Environment variable for APP_LABEL
                        'env': [{
                            'name': 'APP_LABEL',
                            'value': label
                        }, {
                            'name': 'HTTP_PORT',
                            'value': str(port)
                        }],
                        # Readiness probe - Kubernetes uses this to check if pod is ready
                        'readinessProbe': {
                            'httpGet': {
                                'path': '/health',
                                'port': port
                            },
                            'initialDelaySeconds': 5,
                            'periodSeconds': 10
                        },
                        # Liveness probe - Kubernetes restarts pod if this fails
                        'livenessProbe': {
                            'httpGet': {
                                'path': '/health',
                                'port': port
                            },
                            'initialDelaySeconds': 15,
                            'periodSeconds': 20
                        }
                    }]
                }
            }
        }
    }


def create_service(name, namespace, port, service_type):
    """
    Creates a Service spec to expose das_app.

    A Service provides a stable IP and DNS name for pods.
    - ClusterIP: accessible only inside cluster
    - LoadBalancer: gets external IP (if cloud provider supports it)
    """
    return {
        'apiVersion': 'v1',
        'kind': 'Service',
        'metadata': {
            'name': name,
            'namespace': namespace,
            # ownerReferences links Service to DasApp (auto-deletion)
            'ownerReferences': [{
                'apiVersion': 'dasapp.example.com/v1',
                'kind': 'DasApp',
                'name': name,
                'uid': 'placeholder',
                'controller': True,
                'blockOwnerDeletion': True,
            }],
        },
        'spec': {
            # Selector routes traffic to pods with label app={name}
            'selector': {'app': name},
            'ports': [{
                'protocol': 'TCP',
                'port': 80,  # Service listens on port 80
                'targetPort': port  # Forwards to container port
            }],
            'type': service_type
        }
    }
