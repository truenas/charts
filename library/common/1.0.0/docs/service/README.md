# Service

| Key                                                     |   Type    | Required |   Helm Template    |      Default       | Description                                                                                                                           |
| :------------------------------------------------------ | :-------: | :------: | :----------------: | :----------------: | :------------------------------------------------------------------------------------------------------------------------------------ |
| service                                                 |  `dict`   |    ❌    |         ❌         |        `{}`        | Define the service as dicts                                                                                                           |
| service.[service-name]                                  |  `dict`   |    ✅    |         ❌         |        `{}`        | Holds service definition                                                                                                              |
| service.[service-name].enabled                          | `boolean` |    ✅    |         ❌         |      `false`       | Enables or Disables the service                                                                                                       |
| service.[service-name].labels                           |  `dict`   |    ❌    | ✅ (On value only) |        `{}`        | Additional labels for service                                                                                                         |
| service.[service-name].annotations                      |  `dict`   |    ❌    | ✅ (On value only) |        `{}`        | Additional annotations for service                                                                                                    |
| service.[service-name].type                             | `string`  |    ❌    |         ✅         |    `ClusterIP`     | Define the service type (ClusterIP, LoadBalancer, NodePort, ExternalIP, ExternalName)                                                 |
| service.[service-name].publishNotReadyAddresses         | `boolean` |    ❌    |         ❌         |      `false`       | Define whether to publishNotReadyAddresses or not                                                                                     |
| service.[service-name].targetSelector                   | `string`  |    ❌    |         ❌         |        `""`        | Define the pod to link the service, by default will use the primary pod                                                               |
| service.[service-name].ports                            |  `list`   |    ✅    |         ❌         |        `{}`        | Define the ports of the service                                                                                                       |
| service.[service-name].ports.[port-name]                |  `dict`   |    ✅    |         ❌         |        `{}`        | Define the port dict                                                                                                                  |
| service.[service-name].ports.[port-name].port           |   `int`   |    ✅    |         ✅         |                    | Define the port that will be exposed by the service                                                                                   |
| service.[service-name].ports.[port-name].targetPort     |   `int`   |    ❌    |         ✅         | `[port-name].port` | Define the target port (No named ports, as this will be used to assign the containerPort to containers)                               |
| service.[service-name].ports.[port-name].protocol       | `string`  |    ❌    |         ✅         |       `TCP`        | Define the port protocol (HTTP, HTTPS, TCP, UDP). (Also used by the container probes, HTTP and HTTPS are converted to TCP on service) |
| service.[service-name].ports.[port-name].targetSelector | `string`  |    ❌    |         ❌         |       `TCP`        | Define the container to link this port (Must be on under the pod linked above)                                                        |

> When `targetSelector`(s) is empty, it will define auto-select the primary pod/container

---

Appears in:

- `.Values.service`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$ServiceName` (release-name-chart-name-ServiceName)

---

> Those are the common `keys` for all **service**.
> Additional keys, information and examples, see on the specific kind of service.

- [ClusterIP](ClusterIP.md)
- [LoadBalancer](LoadBalancer.md)
- [NodePort](NodePort.md)
- [ExternalName](ExternalName.md)
- [ExternalIP](ExternalIP.md)
