# DasApp Kubernetes Operator

Learning example of a Kubernetes operator using Python and Kopf framework.

## What is this?

This operator watches for `DasApp` custom resources and automatically:
1. Creates a Deployment with das_app containers
2. Creates a Service to expose the app
3. Monitors pod health and updates status
4. Reconciles changes when you update the DasApp

## Architecture

```
User creates DasApp CR
         ↓
    Operator watches
         ↓
    Creates Deployment → Pods running das_app
    Creates Service → Exposes pods
         ↓
    Timer checks health every 30s
         ↓
    Updates DasApp status
```

## Files

- `dasapp_crd.yaml` - CustomResourceDefinition (defines DasApp resource type)
- `operator.py` - Operator logic (handlers for create/update/delete/health)
- `rbac.yaml` - Permissions for operator (ServiceAccount, ClusterRole, Binding)
- `deployment.yaml` - Deployment to run the operator itself
- `example-dasapp.yaml` - Example DasApp to test with
- `Dockerfile` - Builds operator container image
- `requirements.txt` - Python dependencies

## How to deploy (with kind)

### 1. Build and load das_app image

```bash
cd ../  # Go to das_app directory
docker build -t das_app:latest .
kind load docker-image das_app:latest
```

### 2. Build and load operator image

```bash
cd operator/
docker build -t dasapp-operator:latest .
kind load docker-image dasapp-operator:latest
```

### 3. Install CRD (teaches Kubernetes about DasApp)

```bash
kubectl apply -f dasapp_crd.yaml
# Verify:
kubectl get crd dasapps.dasapp.example.com
```

### 4. Install RBAC (permissions for operator)

```bash
kubectl apply -f rbac.yaml
# Verify:
kubectl get serviceaccount dasapp-operator
kubectl get clusterrole dasapp-operator
kubectl get clusterrolebinding dasapp-operator
```

### 5. Deploy the operator

```bash
kubectl apply -f deployment.yaml
# Verify operator is running:
kubectl get pods -l app=dasapp-operator
kubectl logs -f deployment/dasapp-operator
```

### 6. Create a DasApp

```bash
kubectl apply -f example-dasapp.yaml
# Watch what happens:
kubectl get dasapps -w
kubectl get deployments
kubectl get pods
kubectl get services
```

## Testing the operator

### Check DasApp status

```bash
kubectl get dasapps
# Should show: Replicas, Ready, Healthy columns

kubectl describe dasapp my-das-app
# Look at Status section
```

### Access the app

```bash
# Port-forward to the service
kubectl port-forward service/my-das-app 8080:80

# In another terminal:
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/time
```

### Update the DasApp

```bash
# Edit the DasApp
kubectl edit dasapp my-das-app

# Change spec.replicas from 2 to 3
# Save and exit

# Watch operator reconcile:
kubectl get pods -w
# Should see new pod created
```

### Scale up/down

```bash
kubectl patch dasapp my-das-app --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value": 5}]'
# Watch deployment scale to 5 replicas
kubectl get pods -l app=my-das-app
```

### Change the label

```bash
kubectl patch dasapp my-das-app --type='json' -p='[{"op": "replace", "path": "/spec/label", "value": "Updated Label!"}]'
# Pods will restart with new APP_LABEL env var
kubectl exec -it <pod-name> -- env | grep APP_LABEL
```

### Delete the DasApp

```bash
kubectl delete dasapp my-das-app
# Watch garbage collection:
kubectl get deployments
kubectl get services
kubectl get pods
# All should be deleted automatically (ownerReferences)
```

## Understanding the operator code

### Event handlers

- `@kopf.on.create` - Runs when DasApp is created
- `@kopf.on.update` - Runs when DasApp is updated
- `@kopf.on.delete` - Runs when DasApp is deleted
- `@kopf.timer` - Runs periodically (health checks)

### Control loop

Kubernetes operators follow "reconciliation loop":
1. Watch for changes to resources
2. Compare actual state vs desired state
3. Take actions to make actual match desired
4. Repeat

The operator continuously ensures:
- Deployment replicas match `spec.replicas`
- Container image matches `spec.image`
- Service type matches `spec.serviceType`
- Status reflects actual pod health

### Owner references

`ownerReferences` in Deployment/Service metadata links them to DasApp.
When DasApp is deleted, Kubernetes automatically deletes children (garbage collection).

### Status updates

Operator writes to `.status` subresource:
- `ready` - boolean, true when all pods healthy
- `healthyReplicas` - count of running pods
- `lastHealthCheck` - timestamp of last check

Users can read status: `kubectl get dasapp my-das-app -o jsonpath='{.status}'`

## Local development (without cluster)

For faster iteration during development:

```bash
# Install dependencies
pip install -r requirements.txt

# Run operator locally (connects to your kubeconfig cluster)
kopf run --verbose operator.py

# In another terminal, test with kubectl commands
kubectl apply -f example-dasapp.yaml
```

This runs operator on your machine instead of in cluster. Good for debugging.

## Troubleshooting

### Operator pod not starting

```bash
kubectl logs deployment/dasapp-operator
# Check for Python errors or missing permissions
```

### DasApp created but no Deployment

```bash
kubectl logs deployment/dasapp-operator | grep my-das-app
# Look for creation errors
```

### RBAC permission denied

```bash
# Check if ServiceAccount is bound correctly:
kubectl get clusterrolebinding dasapp-operator -o yaml
```

### Image pull errors

```bash
kubectl describe pod <pod-name>
# Check Events section for ImagePullBackOff
# Make sure image is loaded: kind load docker-image das_app:latest
```

## Next steps

Try extending the operator:
- Add `.spec.resources` to set CPU/memory limits
- Add `.spec.ingress` to create Ingress resource
- Add `.spec.autoscaling` for HPA
- Make health check configurable (interval, endpoint)
- Add metrics endpoint for Prometheus
- Handle rolling updates with custom logic

## Resources

- Kopf docs: https://kopf.readthedocs.io/
- Kubernetes Operators: https://kubernetes.io/docs/concepts/extend-kubernetes/operator/
- Custom Resources: https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/
