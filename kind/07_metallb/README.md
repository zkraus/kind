from: https://devopscube.com/kubernetes-kind-cluster-tutorial-setup-and-deploy-apps/



## install MetalLB

`kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml`

`docker network inspect kind | jq -r '.[0].IPAM.Config[].Subnet'`


`metallb-pool.yaml`
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: lb-pool
  namespace: metallb-system
spec:
  addresses:
    - 172.18.0.100 - 172.18.0.200
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2
  namespace: metallb-system
spec:
  ipAddressPools:
    - lb-pool
```

`kubectl apply -f metallb-pool.yaml`