# Common Library

## Naming Scheme

- ConfigMap: `$FullName-$ConfigMapName`
- Secret: `$FullName-$SecretName`
- ServiceAccount: `$FullName-$ServiceAccountName`
- RBAC: `$FullName-$RBACName`
- Service:
  - Primary: `$FullName`
  - Others: `$FullName-$ServiceName`
- Pods:
  - Primary: `$FullName`
  - Others: `$FullName-$PodName`
- Containers: `$ContainerName`
