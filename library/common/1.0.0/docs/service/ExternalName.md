# ExternalName

| Key                                                                  |   Type    | Required | Helm Template | Default | Description                                                                |
| :------------------------------------------------------------------- | :-------: | :------: | :-----------: | :-----: | :------------------------------------------------------------------------- |
| service.[service-name].externalName                                  | `string`  |    ✅    |      ✅       |  `""`   | Define the external name                                                   |
| service.[service-name].clusterIP                                     | `string`  |    ❌    |      ✅       |         | Custom Cluster IP                                                          |
| service.[service-name].sessionAffinity                               | `string`  |    ❌    |      ✅       |         | Define the session affinity (ClientIP, None)                               |
| service.[service-name].sessionAffinityConfig.clientIP.timeoutSeconds |   `int`   |    ❌    |      ✅       |         | Define the timeout for ClientIP session affinity (0-86400)                 |
| service.[service-name].externalIPs                                   |  `list`   |    ❌    |      ❌       |         | Define externalIPs                                                         |
| service.[service-name].externalIPs.[externalIP]                      | `string`  |    ✅    |      ✅       |         | The external IP                                                            |
| service.[service-name].externalTrafficPolicy                         | `string`  |    ❌    |      ✅       |         | Define the external traffic policy (Cluster, Local)                        |

---

Notes:

View common `keys` of `service` in [service Documentation](README.md).

---

Examples:

```yaml
service:
  # Special type
  service-external-name:
    enabled: true
    primary: true
    type: ExternalName
    externalName: external-name
    clusterIP: 172.16.20.233
    publishNotReadyAddresses: true
    externalIPs:
      - 10.200.230.34
    sessionAffinity: ClientIP
    sessionAffinityConfig:
      clientIP:
        timeoutSeconds: 86400
    externalTrafficPolicy: Cluster
    ports:
      port-name:
        enabled: true
        primary: true
        targetSelector: container-name
        port: 80
        protocol: http
```
