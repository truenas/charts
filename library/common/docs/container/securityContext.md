# Security Context

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key                                      |   Type    |            Required            | Helm Template |                              Default                               | Description                                                                              |
| :--------------------------------------- | :-------: | :----------------------------: | :-----------: | :----------------------------------------------------------------: | :--------------------------------------------------------------------------------------- |
| securityContext                          |  `dict`   |               ✅               |      ❌       |             `{{ .Values.securityContext.container }}`              | Define securityContext for the container                                                 |
| securityContext.runAsUser                |   `int`   |               ✅               |      ❌       |        `{{ .Values.securityContext.container.runAsUser }}`         | Define the runAsUser for the container                                                   |
| securityContext.runAsGroup               |   `int`   |               ✅               |      ❌       |        `{{ .Values.securityContext.container.runAsGroup }}`        | Define the runAsGroup for the container                                                  |
| securityContext.readOnlyRootFilesystem   | `boolean` |               ✅               |      ❌       |  `{{ .Values.securityContext.container.readOnlyRootFilesystem }}`  | Define the readOnlyRootFilesystem for the container                                      |
| securityContext.allowPrivilegeEscalation | `boolean` |               ✅               |      ❌       | `{{ .Values.securityContext.container.allowPrivilegeEscalation }}` | Define the allowPrivilegeEscalation for the container                                    |
| securityContext.privileged               | `boolean` |               ✅               |      ❌       |        `{{ .Values.securityContext.container.privileged }}`        | Define the privileged for the container                                                  |
| securityContext.runAsNonRoot             | `boolean` |               ✅               |      ❌       |       `{{ .Values.securityContext.container.runAsNonRoot }}`       | Define the runAsNonRoot for the container                                                |
| securityContext.capabilities             |  `dict`   |               ✅               |      ❌       |       `{{ .Values.securityContext.container.capabilities }}`       | Define the capabilities for the container                                                |
| securityContext.capabilities.add         |  `list`   |               ✅               |      ❌       |     `{{ .Values.securityContext.container.capabilities.add }}`     | Define the capabilities.add for the container                                            |
| securityContext.capabilities.drop        |  `list`   |               ✅               |      ❌       |    `{{ .Values.securityContext.container.capabilities.drop }}`     | Define the capabilities.drop for the container                                           |
| securityContext.seccompProfile           |  `dict`   |               ✅               |      ❌       |      `{{ .Values.securityContext.container.seccompProfile }}`      | Define the seccompProfile for the container                                              |
| securityContext.seccompProfile.type      | `string`  |               ✅               |      ❌       |   `{{ .Values.securityContext.container.seccompProfile.type }}`    | Define the seccompProfile.type for the container (RuntimeDefault, Localhost, Unconfined) |
| securityContext.seccompProfile.profile   | `string`  | ✅ (Only when Localhost type ) |      ❌       |  `{{ .Values.securityContext.container.seccompProfile.profile }}`  | Define the seccompProfile.profile for the container (Only when type is Localhost)        |

> Each value that is not defined in the `securityContext` under the container level, it will get replaced with the value defined `.Values.securityContext.container`.
> If a capability is defined in either `add` or `drop` on container level, it will **NOT** get merged
> with the value(s) from the `.Values.securityContext.container.capabilities.[add/drop]`. But it will override them.

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].securityContext`

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
          securityContext:
            runAsNonRoot: true
            runAsUser: 568
            runAsGroup: 568
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            privileged: false
            seccompProfile:
              type: Localhost
              profile: path/to/profile.json
            capabilities:
              add: []
              drop:
                - ALL
```

---

Notes:

When setting capabilities for containers, remember to **NOT** include `CAP_` prefix.
For example, `CAP_NET_ADMIN` should be `NET_ADMIN`.
