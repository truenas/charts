# Service

| Key                                                                  |   Type    |        Required         |   Helm Template    |      Default       | Description                                                                                                                           |
| :------------------------------------------------------------------- | :-------: | :---------------------: | :----------------: | :----------------: | :------------------------------------------------------------------------------------------------------------------------------------ |
| service                                                              |  `dict`   |           ❌            |         ❌         |        `{}`        | Define the service as dicts                                                                                                           |
| service.[service-name]                                               |  `dict`   |           ✅            |         ❌         |        `{}`        | Holds service definition                                                                                                              |
| service.[service-name].enabled                                       | `boolean` |           ✅            |         ❌         |      `false`       | Enables or Disables the service                                                                                                       |
| service.[service-name].labels                                        |  `dict`   |           ❌            | ✅ (On value only) |        `{}`        | Additional labels for service                                                                                                         |
| service.[service-name].annotations                                   |  `dict`   |           ❌            | ✅ (On value only) |        `{}`        | Additional annotations for service                                                                                                    |
| service.[service-name].type                                          | `string`  |           ❌            |         ✅         |    `ClusterIP`     | Define the service type (ClusterIP, LoadBalancer, NodePort, ExternalIP, ExternalName)                                                 |
| service.[service-name].publishNotReadyAddresses                      | `boolean` |           ❌            |         ❌         |      `false`       | Define whether to publishNotReadyAddresses or not                                                                                     |
| service.[service-name].externalIPs                                   |  `list`   |           ❌            |         ❌         |                    | Define externalIPs                                                                                                                    |
| service.[service-name].externalIPs.[externalIP]                      | `string`  |           ✅            |         ✅         |                    | The external IP                                                                                                                       |
| service.[service-name].sharedKey                                     | `string`  |           ❌            |         ✅         |    `$FullName`     | Custom Shared Key for MetalLB Annotation                                                                                              |
| service.[service-name].clusterIP                                     | `string`  |           ❌            |         ✅         |                    | Custom Cluster IP                                                                                                                     |
| service.[service-name].ipFamilyPolicy                                | `string`  |           ❌            |         ✅         |                    | Define the ipFamilyPolicy (SingleStack, PreferDualStack, RequireDualStack)                                                            |
| service.[service-name].ipFamilies                                    |  `list`   |           ❌            |         ❌         |                    | Define the ipFamilies                                                                                                                 |
| service.[service-name].ipFamilies.[ipFamily]                         | `string`  |           ✅            |         ✅         |                    | Define the ipFamily (IPv4, IPv6)                                                                                                      |
| service.[service-name].loadBalancerIP                                | `string`  |           ❌            |         ✅         |                    | Define the load balancer IP                                                                                                           |
| service.[service-name].loadBalancerSourceRanges                      |  `list`   |           ❌            |         ❌         |                    | Define the load balancer source ranges                                                                                                |
| service.[service-name].loadBalancerSourceRanges.[source-range]       | `string`  |           ✅            |         ✅         |                    | Define the load balancer source range                                                                                                 |
| service.[service-name].externalTrafficPolicy                         | `string`  |           ❌            |         ✅         |                    | Define the external traffic policy (Cluster, Local)                                                                                   |
| service.[service-name].sessionAffinity                               | `string`  |           ❌            |         ✅         |                    | Define the session affinity (ClientIP, None)                                                                                          |
| service.[service-name].sessionAffinityConfig.clientIP.timeoutSeconds |   `int`   |           ❌            |         ✅         |                    | Define the timeout for ClientIP session affinity (0-86400)                                                                            |
| service.[service-name].targetSelector                                | `string`  |           ❌            |         ❌         |        `""`        | Define the pod to link the service, by default will use the primary pod                                                               |
| service.[service-name].ports                                         |  `list`   |           ✅            |         ❌         |        `{}`        | Define the ports of the service                                                                                                       |
| service.[service-name].ports.[port-name]                             |  `dict`   |           ✅            |         ❌         |        `{}`        | Define the port dict                                                                                                                  |
| service.[service-name].ports.[port-name].port                        |   `int`   |           ✅            |         ✅         |                    | Define the port that will be exposed by the service                                                                                   |
| service.[service-name].ports.[port-name].nodePort                    |   `int`   | ✅ (Only NodePort type) |         ✅         |                    | Define the node port that will be exposed on the node                                                                                 |
| service.[service-name].ports.[port-name].targetPort                  |   `int`   |           ❌            |         ✅         | `[port-name].port` | Define the target port (No named ports, as this will be used to assign the containerPort to containers)                               |
| service.[service-name].ports.[port-name].protocol                    | `string`  |           ❌            |         ✅         |       `TCP`        | Define the port protocol (HTTP, HTTPS, TCP, UDP). (Also used by the container probes, HTTP and HTTPS are converted to TCP on service) |
| service.[service-name].ports.[port-name].targetSelector              | `string`  |           ❌            |         ❌         |       `TCP`        | Define the container to link this port (Must be on under the pod linked above)                                                        |

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
    publishNotReadyAddresses: true
    ipFamilyPolicy: SingleStack
    ipFamilies:
      - IPv4
    externalIPs:
      - 10.200.230.34
    sessionAffinity: ClientIP
    targetSelector: pod-name
    ports:
      port-name:
        enabled: true
        primary: true
        targetSelector: container-name
        port: 80
        protocol: HTTP
        targetPort: 8080

  service-lb:
    enabled: true
    primary: true
    type: LoadBalancer
    loadBalancerIP: 10.100.100.2
    loadBalancerSourceRanges:
      - 10.100.100.0/24
    clusterIP: 172.16.20.233
    sharedKey: custom-shared-key
    publishNotReadyAddresses: true
    ipFamilyPolicy: SingleStack
    ipFamilies:
      - IPv4
    externalIPs:
      - 10.200.230.34
    sessionAffinity: ClientIP
    externalTrafficPolicy: Cluster
    targetSelector: pod-name
    ports:
      port-name:
        enabled: true
        primary: true
        targetSelector: container-name
        port: 80
        protocol: HTTP
        targetPort: 8080

  service-nodeport:
    enabled: true
    primary: true
    type: NodePort
    clusterIP: 172.16.20.233
    publishNotReadyAddresses: true
    externalIPs:
      - 10.200.230.34
    sessionAffinity: ClientIP
    externalTrafficPolicy: Cluster
    targetSelector: pod-name
    ports:
      port-name:
        enabled: true
        primary: true
        targetSelector: container-name
        port: 80
        protocol: HTTP
        targetPort: 8080
        nodePort: 30080

  service-externalname:
    enabled: true
    primary: true
    type: ExternalName
    externalName: external-name
    clusterIP: 172.16.20.233
    publishNotReadyAddresses: true
    externalIPs:
      - 10.200.230.34
    sessionAffinity: ClientIP
    externalTrafficPolicy: Cluster
    ports:
      port-name:
        enabled: true
        primary: true
        targetSelector: container-name
        port: 80
        protocol: HTTP

  other-service-name:
    enabled: true
    type: ClusterIP
    ports:
      other-port-name:
        enabled: true
        primary: true
```
