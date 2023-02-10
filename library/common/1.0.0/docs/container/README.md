# Container

Assume every key bellow has a prefix of `workload.[workload-name].podSpec`.

| Key                                                      |     Type      |     Required      |   Helm Template    | Default | Description                                                                                    |
| :------------------------------------------------------- | :-----------: | :---------------: | :----------------: | :-----: | :--------------------------------------------------------------------------------------------- | --- |
| containers.[container-name]                              |    `dict`     |        ✅         |         ❌         |  `{}`   | Define the container as dict                                                                   |
| containers.[container-name].enabled                      |   `boolean`   |        ✅         |         ❌         | `false` | Enables or Disables the container                                                              |
| containers.[container-name].primary                      |   `boolean`   |        ✅         |         ❌         | `false` | Sets the container as primary                                                                  |
| containers.[container-name].stdin                        |   `boolean`   |        ❌         |         ❌         | `false` | whether to enable stdin or not                                                                 |
| containers.[container-name].tty                          |   `boolean`   |        ❌         |         ❌         | `false` | whether to enable tty or not                                                                   |
| containers.[container-name].command                      | `list/string` |        ❌         |         ✅         |  `[]`   | Define command(s). If it's single, can be defined as string                                    |
| containers.[container-name].args                         | `list/string` |        ❌         |         ✅         |  `[]`   | Define arg(s). If it's single, can be defined as string                                        |
| containers.[container-name].extraArgs                    | `list/string` |        ❌         |         ✅         |  `[]`   | Define extraArg(s). Those are appended after the `args`. Useful for user defined args from GUI |
| containers.[container-name].termination                  |    `dict`     |        ❌         |         ❌         |  `{}`   | Define termination for the container                                                           |
| containers.[container-name].termination.messagePath      |   `string`    |        ❌         |         ✅         |  `""`   | Define termination message path for the container                                              |
| containers.[container-name].termination.messagePolicy    |   `string`    |        ❌         |         ✅         |  `""`   | Define termination message policy for the container                                            |
| containers.[container-name].lifecycle                    |    `dict`     |        ❌         |         ❌         |  `{}`   | Define lifecycle for the container                                                             |
| containers.[container-name].lifecycle.preStop            |    `dict`     |        ❌         |         ❌         |  `{}`   | Define preStop lifecycle                                                                       |
| containers.[container-name].lifecycle.postStart          |    `dict`     |        ❌         |         ❌         |  `{}`   | Define preStop lifecycle                                                                       |
| containers.[container-name].lifecycle.[hook].type        |   `string`    |        ❌         |         ❌         |  `""`   | Define hook type (exec, http)                                                                  |
| containers.[container-name].lifecycle.[hook].command     | `list/string` | ✅ (On exec type) |         ✅         |  `""`   | Define command(s). If it's single, can be defined as string (Only when exec type is used)      |     |
| containers.[container-name].lifecycle.[hook].port        |     `int`     | ✅ (On http type) |         ✅         |  `""`   | Define the port, (Only when http type is used)                                                 |     |
| containers.[container-name].lifecycle.[hook].host        |   `string`    |        ❌         |         ✅         |         | Define the host, k8s defaults to POD IP (Only when http type is used)                          |     |
| containers.[container-name].lifecycle.[hook].path        |   `string`    |        ❌         |         ✅         |   `/`   | Define the path (Only when http type is used)                                                  |     |
| containers.[container-name].lifecycle.[hook].scheme      |   `string`    |        ❌         |         ✅         | `HTTP`  | Define the scheme (Only when http type is used)                                                |     |
| containers.[container-name].lifecycle.[hook].httpHeaders |    `dict`     |        ❌         | ✅ (On value only) |  `{}`   | Define the httpHeaders in key-value pairs (Only when http type is used)                        |     |

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$ContainerName` (release-name-chart-name-container-name)

---

Examples:

```yaml
workload:
  workload-name:
    enabled: true
    primary: true
    labels:
      key: value
    annotations:
      key: value
    podSpec:
      containers:
        container-name:
          enabled: true
          primary: true
          stdin: true
          tty: true
          command:
            - command
          args: arg
          extraArgs:
            - extraArg
          termination:
            messagePath: /dev/termination-log
            messagePolicy: File
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
              scheme: HTTP
              httpHeaders:
                key: value
```
