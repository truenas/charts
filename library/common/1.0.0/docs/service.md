# Service

| Key                                   |   Type    | Required |   Helm Template    |   Default   | Description                                                                           |
| :------------------------------------ | :-------: | :------: | :----------------: | :---------: | :------------------------------------------------------------------------------------ |
| service                               |  `dict`   |    ❌    |         ❌         |    `{}`     | Define the service as dicts                                                           |
| service.[service-name]                |  `dict`   |    ✅    |         ❌         |    `{}`     | Holds service definition                                                              |
| service.[service-name].enabled        | `boolean` |    ✅    |         ❌         |   `false`   | Enables or Disables the service                                                       |
| service.[service-name].labels         |  `dict`   |    ❌    | ✅ (On value only) |    `{}`     | Additional labels for service                                                         |
| service.[service-name].annotations    |  `dict`   |    ❌    | ✅ (On value only) |    `{}`     | Additional annotations for service                                                    |
| service.[service-name].type           | `string`  |    ❌    |         ✅         | `ClusterIP` | Define the service type (ClusterIP, LoadBalancer, NodePort, ExternalIP, ExternalName) |
| service.[service-name].sharedKey      | `string`  |    ❌    |         ✅         | `$FullName` | Custom Shared Key for MetalLB Annotation                                              |
| service.[service-name].targetSelector | `string`  |    ❌    |         ✅         |    `""`     | Define the pod to link the service, by default will use the primary pod               |
| service.[service-name].ports          |  `list`   |    ✅    |         ❌         |    `{}`     | Define the ports of the service                                                       |

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
  service-name:
    enabled: true
    primary: true
    type: ClusterIP
    targetSelector: pod-name
    sharedKey: custom-shared-key
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
