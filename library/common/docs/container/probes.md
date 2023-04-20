# Probes

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key                                          |     Type      |           Required            |   Helm Template    |                                     Default                                     | Description                                                                               |
| :------------------------------------------- | :-----------: | :---------------------------: | :----------------: | :-----------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------- |
| probes                                       |    `dict`     |              ✅               |         ❌         |                                      `{}`                                       | Define probes for the container                                                           |
| probes.liveness                              |    `dict`     |              ✅               |         ❌         |                                      `{}`                                       | Define the liveness probe                                                                 |
| probes.readiness                             |    `dict`     |              ✅               |         ❌         |                                      `{}`                                       | Define the readiness probe                                                                |
| probes.startup                               |    `dict`     |              ✅               |         ❌         |                                      `{}`                                       | Define the startup probe                                                                  |
| probes.[probe-name].enabled                  |   `boolean`   |              ✅               |         ❌         |                                     `true`                                      | Enable or disable the probe                                                               |
| probes.[probe-name].type                     |   `string`    |              ❌               |         ✅         |                                     `http`                                      | Define probe type (exec, http, https, tcp, grpc) (Used as a scheme in http(s) types)      |
| probes.[probe-name].command                  | `list/string` |       ✅ (On exec type)       |         ✅         |                                      `""`                                       | Define command(s). If it's single, can be defined as string (Only when exec type is used) |
| probes.[probe-name].port                     |     `int`     | ✅ (On grpc/tcp/http(s) type) |         ✅         |                                      `""`                                       | Define the port, (Only when grpc/tcp/http/https type is used)                             |
| probes.[probe-name].path                     |   `string`    |              ❌               |         ✅         |                                       `/`                                       | Define the path (Only when https/http type is used)                                       |
| probes.[probe-name].httpHeaders              |    `dict`     |              ❌               | ✅ (On value only) |                                      `{}`                                       | Define the httpHeaders in key-value pairs (Only when http/https type is used)             |
| probes.[probe-name].spec.initialDelaySeconds |     `int`     |              ❌               |         ❌         | `{{ .Values.fallbackDefaults.probeTimeouts.[probe-name].initialDelaySeconds }}` | Define the initialDelaySeconds in seconds                                                 |
| probes.[probe-name].spec.periodSeconds       |     `int`     |              ❌               |         ❌         |    `{{ .Values.fallbackDefaults.probeTimeouts.[probe-name].periodSeconds }}`    | Define the periodSeconds in seconds                                                       |
| probes.[probe-name].spec.timeoutSeconds      |     `int`     |              ❌               |         ❌         |   `{{ .Values.fallbackDefaults.probeTimeouts.[probe-name].timeoutSeconds }}`    | Define the timeoutSeconds in seconds                                                      |
| probes.[probe-name].spec.failureThreshold    |     `int`     |              ❌               |         ❌         |  `{{ .Values.fallbackDefaults.probeTimeouts.[probe-name].failureThreshold }}`   | Define the failureThreshold in seconds                                                    |
| probes.[probe-name].spec.successThreshold    |     `int`     |              ❌               |         ❌         |  `{{ .Values.fallbackDefaults.probeTimeouts.[probe-name].successThreshold }}`   | Define the successThreshold in seconds (liveness and startup must always be 1)            |

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].probes`

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
          probes:
            liveness:
              enabled: true
              type: https
              port: 8080
              path: /healthz
              httpHeaders:
                key1: value1
                key2: value2
              spec:
                initialDelaySeconds: 10
                periodSeconds: 10
                timeoutSeconds: 10
                failureThreshold: 10
                successThreshold: 10
            readiness:
              enabled: true
              type: tcp
              port: 8080
              spec:
                initialDelaySeconds: 10
                periodSeconds: 10
                timeoutSeconds: 10
                failureThreshold: 10
                successThreshold: 10
            startup:
              enabled: true
              type: exec
              command:
                - command1
                - command2
              spec:
                initialDelaySeconds: 10
                periodSeconds: 10
                timeoutSeconds: 10
                failureThreshold: 10
                successThreshold: 10
```
