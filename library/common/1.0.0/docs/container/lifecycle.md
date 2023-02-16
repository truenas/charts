# Lifecycle

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key                          |     Type      |     Required      |   Helm Template    | Default | Description                                                                               |
| :--------------------------- | :-----------: | :---------------: | :----------------: | :-----: | :---------------------------------------------------------------------------------------- |
| lifecycle                    |    `dict`     |        ❌         |         ❌         |  `{}`   | Define lifecycle for the container                                                        |
| lifecycle.preStop            |    `dict`     |        ❌         |         ❌         |  `{}`   | Define preStop lifecycle                                                                  |
| lifecycle.postStart          |    `dict`     |        ❌         |         ❌         |  `{}`   | Define preStop lifecycle                                                                  |
| lifecycle.[hook].type        |   `string`    |        ❌         |         ❌         |  `""`   | Define hook type (exec, http, https) (Used as a scheme in http(s) types)                  |
| lifecycle.[hook].command     | `list/string` | ✅ (On exec type) |         ✅         |  `""`   | Define command(s). If it's single, can be defined as string (Only when exec type is used) |
| lifecycle.[hook].port        |     `int`     | ✅ (On http type) |         ✅         |  `""`   | Define the port, (Only when http(s) type is used)                                         |
| lifecycle.[hook].host        |   `string`    |        ❌         |         ✅         |         | Define the host, k8s defaults to POD IP (Only when http(s) type is used)                  |
| lifecycle.[hook].path        |   `string`    |        ❌         |         ✅         |   `/`   | Define the path (Only when http(s) type is used)                                          |
| lifecycle.[hook].httpHeaders |    `dict`     |        ❌         | ✅ (On value only) |  `{}`   | Define the httpHeaders in key-value pairs (Only when http(s) type is used)                |

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
              type: exec
              command:
                - command
            postStart:
              type: http
              port: 8080
              host: localhost
              path: /path
              httpHeaders:
                key: value
```
