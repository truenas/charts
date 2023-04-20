# Resources

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key                       |   Type   | Required | Helm Template |                          Default                           | Description                                  |
| :------------------------ | :------: | :------: | :-----------: | :--------------------------------------------------------: | :------------------------------------------- |
| resources                 |  `dict`  |    ✅    |      ❌       |         `{{ .Values.resources }}`         | Define resources for the container           |
| resources.requests        |  `dict`  |    ✅    |      ❌       |    `{{ .Values.resources.requests }}`     | Define the requests for the container        |
| resources.requests.cpu    | `string` |    ✅    |      ❌       |  `{{ .Values.resources.requests.cpu }}`   | Define the requests.cpu for the container    |
| resources.requests.memory | `string` |    ✅    |      ❌       | `{{ .Values.resources.requests.memory }}` | Define the requests.memory for the container |
| resources.limits          |  `dict`  |    ❌    |      ❌       |     `{{ .Values.resources.limits }}`      | Define the limits for the container          |
| resources.limits.cpu      | `string` |    ❌    |      ❌       |   `{{ .Values.resources.limits.cpu }}`    | Define the limits.cpu for the container      |
| resources.limits.memory   | `string` |    ❌    |      ❌       |  `{{ .Values.resources.limits.memory }}`  | Define the limits.memory for the container   |

> Each value that is not defined in the `resources` under the container level, it will get replaced with the value defined `.Values.resources`.
> `requests` is **required**, because without it, kubernetes uses the `limits` as the `requests`. Which can lead pods to be evicted when they reach their `limits` or not even scheduled.
> `limits` is **optional**, can be set to "unlimited" by setting it's values (`cpu` and `memory`) to `0`.

Regex Match:

- [CPU Regex match](https://regex101.com/r/D4HouI/1)
- [Regex match](https://regex101.com/r/D4HouI/1

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].resources`

---

Examples:

```yaml
workload:
  workload-name:
    enabled: true
    primary: true
    podSpec:
      containers:
        container-name:
          enabled: true
          primary: true
          resources:
            limits:
              cpu: 1
              memory: 1Gi
            requests:
              cpu: 10m
              memory: 50Mi
```
