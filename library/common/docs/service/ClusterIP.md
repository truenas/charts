# ClusterIP

| Key                                                                  |   Type    | Required | Helm Template | Default | Description                                                                |
| :------------------------------------------------------------------- | :-------: | :------: | :-----------: | :-----: | :------------------------------------------------------------------------- |
| service.[service-name].clusterIP                                     | `string`  |    ❌    |      ✅       |         | Custom Cluster IP                                                          |
| service.[service-name].ipFamilyPolicy                                | `string`  |    ❌    |      ✅       |         | Define the ipFamilyPolicy (SingleStack, PreferDualStack, RequireDualStack) |
| service.[service-name].ipFamilies                                    |  `list`   |    ❌    |      ❌       |         | Define the ipFamilies                                                      |
| service.[service-name].ipFamilies.[ipFamily]                         | `string`  |    ✅    |      ✅       |         | Define the ipFamily (IPv4, IPv6)                                           |
| service.[service-name].sessionAffinity                               | `string`  |    ❌    |      ✅       |         | Define the session affinity (ClientIP, None)                               |
| service.[service-name].sessionAffinityConfig.clientIP.timeoutSeconds |   `int`   |    ❌    |      ✅       |         | Define the timeout for ClientIP session affinity (0-86400)                 |
| service.[service-name].externalIPs                                   |  `list`   |            ❌             |         ❌         |                    | Define externalIPs                                                                                                                    |
| service.[service-name].externalIPs.[externalIP]                      | `string`  |            ✅             |         ✅         |                    | The external IP                                                                                                                       |

---

Notes:

View common `keys` of `service` in [service Documentation](README.md).

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
    sessionAffinityConfig:
      clientIP:
        timeoutSeconds: 86400
    targetSelector: pod-name
    ports:
      port-name:
        enabled: true
        primary: true
        targetSelector: container-name
        port: 80
        protocol: http
        targetPort: 8080
```
