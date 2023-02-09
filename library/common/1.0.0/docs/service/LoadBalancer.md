# LoadBalancer

| Key                                                                  |   Type    | Required | Helm Template |   Default   | Description                                                                |
| :------------------------------------------------------------------- | :-------: | :------: | :-----------: | :---------: | :------------------------------------------------------------------------- |
| service.[service-name].sharedKey                                     | `string`  |    ❌    |      ✅       | `$FullName` | Custom Shared Key for MetalLB Annotation                                   |
| service.[service-name].clusterIP                                     | `string`  |    ❌    |      ✅       |             | Custom Cluster IP                                                          |
| service.[service-name].ipFamilyPolicy                                | `string`  |    ❌    |      ✅       |             | Define the ipFamilyPolicy (SingleStack, PreferDualStack, RequireDualStack) |
| service.[service-name].ipFamilies                                    |  `list`   |    ❌    |      ❌       |             | Define the ipFamilies                                                      |
| service.[service-name].ipFamilies.[ipFamily]                         | `string`  |    ✅    |      ✅       |             | Define the ipFamily (IPv4, IPv6)                                           |
| service.[service-name].sessionAffinity                               | `string`  |    ❌    |      ✅       |             | Define the session affinity (ClientIP, None)                               |
| service.[service-name].sessionAffinityConfig.clientIP.timeoutSeconds |   `int`   |    ❌    |      ✅       |             | Define the timeout for ClientIP session affinity (0-86400)                 |
| service.[service-name].externalIPs                                   |  `list`   |    ❌    |      ❌       |             | Define externalIPs                                                         |
| service.[service-name].externalIPs.[externalIP]                      | `string`  |    ✅    |      ✅       |             | The external IP                                                            |
| service.[service-name].loadBalancerIP                                | `string`  |    ❌    |      ✅       |             | Define the load balancer IP                                                |
| service.[service-name].loadBalancerSourceRanges                      |  `list`   |    ❌    |      ❌       |             | Define the load balancer source ranges                                     |
| service.[service-name].loadBalancerSourceRanges.[source-range]       | `string`  |    ✅    |      ✅       |             | Define the load balancer source range                                      |
| service.[service-name].externalTrafficPolicy                         | `string`  |    ❌    |      ✅       |             | Define the external traffic policy (Cluster, Local)                        |

---

Notes:

View common `keys` of `service` in [service Documentation](README.md).

---

Examples:

```yaml
service:
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
    sessionAffinityConfig:
      clientIP:
        timeoutSeconds: 86400
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
```
