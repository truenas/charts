# ExternalIP

| Key                                                                  |   Type    | Required | Helm Template | Default | Description                                                |
| :------------------------------------------------------------------- | :-------: | :------: | :-----------: | :-----: | :--------------------------------------------------------- |
| service.[service-name].externalIP                                    | `string`  |    ✅    |      ✅       |         | Define External IP for headless service                    |
| service.[service-name].addressType                                   | `string`  |    ❌    |      ✅       | `IPv4`  | Define the addressType for External IP                     |
| service.[service-name].sessionAffinity                               | `string`  |    ❌    |      ✅       |         | Define the session affinity (ClientIP, None)               |
| service.[service-name].sessionAffinityConfig.clientIP.timeoutSeconds |   `int`   |    ❌    |      ✅       |         | Define the timeout for ClientIP session affinity (0-86400) |
| service.[service-name].externalIPs                                   |  `list`   |    ❌    |      ❌       |         | Define externalIPs                                         |
| service.[service-name].externalIPs.[externalIP]                      | `string`  |    ✅    |      ✅       |         | The external IP                                            |
| service.[service-name].externalTrafficPolicy                         | `string`  |    ❌    |      ✅       |         | Define the external traffic policy (Cluster, Local)        |

---

Notes:

View common `keys` of `service` in [service Documentation](README.md).

---

Examples:

```yaml
service:
  # Special type
  service-externalip:
    enabled: true
    primary: true
    type: ExternalIP
    externalIP: 1.1.1.1
    addressType: IPv4
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
        targetPort: 8080
        protocol: HTTP
```
