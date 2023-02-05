# Service

| Key                                                            |   Type    | Required |   Helm Template    |   Default   | Description                                                                           |
| :------------------------------------------------------------- | :-------: | :------: | :----------------: | :---------: | :------------------------------------------------------------------------------------ |
| service                                                        |  `dict`   |    ❌    |         ❌         |    `{}`     | Define the service as dicts                                                           |
| service.[service-name]                                         |  `dict`   |    ✅    |         ❌         |    `{}`     | Holds service definition                                                              |
| service.[service-name].enabled                                 | `boolean` |    ✅    |         ❌         |   `false`   | Enables or Disables the service                                                       |
| service.[service-name].labels                                  |  `dict`   |    ❌    | ✅ (On value only) |    `{}`     | Additional labels for service                                                         |
| service.[service-name].annotations                             |  `dict`   |    ❌    | ✅ (On value only) |    `{}`     | Additional annotations for service                                                    |
| service.[service-name].type                                    | `string`  |    ❌    |         ✅         | `ClusterIP` | Define the service type (ClusterIP, LoadBalancer, NodePort, ExternalIP, ExternalName) |
| service.[service-name].publishNotReadyAddresses                | `boolean` |    ❌    |         ❌         |   `false`   | Define whether to publishNotReadyAddresses or not                                     |
| service.[service-name].sharedKey                               | `string`  |    ❌    |         ✅         | `$FullName` | Custom Shared Key for MetalLB Annotation                                              |
| service.[service-name].clusterIP                               | `string`  |    ❌    |         ✅         |             | Custom Cluster IP                                                                     |
| service.[service-name].ipFamilyPolicy                          | `string`  |    ❌    |         ✅         |             | Define the ipFamilyPolicy (SingleStack, PreferDualStack, RequireDualStack)            |
| service.[service-name].ipFamilies                              |  `list`   |    ❌    |         ❌         |             | Define the ipFamilies                                                                 |
| service.[service-name].ipFamilies.[ipFamily]                   | `string`  |    ✅    |         ✅         |             | Define the ipFamily (IPv4, IPv6)                                                      |
| service.[service-name].loadBalancerIP                          | `string`  |    ❌    |         ✅         |             | Define the load balancer IP                                                           |
| service.[service-name].loadBalancerSourceRanges                |  `list`   |    ❌    |         ❌         |             | Define the load balancer source ranges                                                |
| service.[service-name].loadBalancerSourceRanges.[source-range] | `string`  |    ✅    |         ✅         |             | Define the load balancer source range                                                 |
| service.[service-name].externalTrafficPolicy                   | `string`  |    ❌    |         ✅         |             | Define the external traffic policy (Cluster, Local)                                   |
| service.[service-name].targetSelector                          | `string`  |    ❌    |         ✅         |    `""`     | Define the pod to link the service, by default will use the primary pod               |
| service.[service-name].ports                                   |  `list`   |    ✅    |         ❌         |    `{}`     | Define the ports of the service                                                       |

---

Appears in:

- `.Values.service`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$ServiceName` (release-name-chart-name-ServiceName)

---

Examples:

```yaml
service:
  service-clusterip:
    enabled: true
    primary: true
    publishNotReadyAddresses: true
    clusterIP: 172.16.20.233
    ipFamilyPolicy: SingleStack
    ipFamilies:
      - IPv4
    targetSelector: pod-name
    ports:
      port-name:
        enabled: true
        primary: true
        container-name: container-name

  service-lb:
    enabled: true
    primary: true
    type: LoadBalancer
    loadBalancerIP: 10.100.100.2
    loadBalancerSourceRanges:
      - 10.100.100.0/24
    clusterIP: 172.16.20.233
    sharedKey: custom-shared-key
    ipFamilyPolicy: SingleStack
    ipFamilies:
      - IPv4
    externalTrafficPolicy: Cluster
    targetSelector: pod-name
    ports:
      port-name:
        enabled: true
        primary: true
        container-name: container-name

  other-service-name:
    enabled: true
    type: ClusterIP
    ports:
      other-port-name:
        enabled: true
        primary: true
```
