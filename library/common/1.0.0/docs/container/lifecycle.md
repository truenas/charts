# Lifecycle

Assume every key bellow has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key                          |     Type      |     Required      |   Helm Template    | Default | Description                                                                               |
| :--------------------------- | :-----------: | :---------------: | :----------------: | :-----: | :---------------------------------------------------------------------------------------- |
| lifecycle                    |    `dict`     |        ❌         |         ❌         |  `{}`   | Define lifecycle for the container                                                        |
| lifecycle.preStop            |    `dict`     |        ❌         |         ❌         |  `{}`   | Define preStop lifecycle                                                                  |
| lifecycle.postStart          |    `dict`     |        ❌         |         ❌         |  `{}`   | Define preStop lifecycle                                                                  |
| lifecycle.[hook].type        |   `string`    |        ❌         |         ❌         |  `""`   | Define hook type (EXEC, HTTP, HTTPS) (Used as a scheme in HTTP(S) types)                  |
| lifecycle.[hook].command     | `list/string` | ✅ (On EXEC type) |         ✅         |  `""`   | Define command(s). If it's single, can be defined as string (Only when EXEC type is used) |
| lifecycle.[hook].port        |     `int`     | ✅ (On HTTP type) |         ✅         |  `""`   | Define the port, (Only when HTTP(S) type is used)                                         |
| lifecycle.[hook].host        |   `string`    |        ❌         |         ✅         |         | Define the host, k8s defaults to POD IP (Only when HTTP(S) type is used)                  |
| lifecycle.[hook].path        |   `string`    |        ❌         |         ✅         |   `/`   | Define the path (Only when HTTP(S) type is used)                                          |
| lifecycle.[hook].httpHeaders |    `dict`     |        ❌         | ✅ (On value only) |  `{}`   | Define the httpHeaders in key-value pairs (Only when HTTP(S) type is used)                |

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].lifecycle`

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
          lifecycle:
            preStop:
              type: EXEC
              command:
                - command
            postStart:
              type: HTTP
              port: 8080
              host: localhost
              path: /path
              httpHeaders:
                key: value
```
