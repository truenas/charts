# Fixed Env

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key                  |   Type   | Required | Helm Template |                     Default                     | Description                                                                   |
| :------------------- | :------: | :------: | :-----------: | :---------------------------------------------: | :---------------------------------------------------------------------------- |
| fixedEnv             |  `dict`  |    ❌    |      ❌       |                      `{}`                       | Override fixed Envs for the container                                         |
| fixedEnv.TZ          | `string` |    ❌    |      ❌       |               `{{ .Values.TZ }}`                | Override default TZ for the container                                         |
| fixedEnv.UMASK       | `string` |    ❌    |      ❌       | `{{ .Values.securityContext.container.UMASK }}` | Override the default UMASK for the container (Applies to UMASK and UMASK_SET) |
| fixedEnv.PUID        | `string` |    ❌    |      ❌       | `{{ .Values.securityContext.container.PUID }}`  | Override the default PUID for the container (Applies to PUID. USER_ID, UID)   |
| fixedEnv.NVIDIA_CAPS |  `list`  |    ❌    |      ❌       |      `{{ .Values.resources.NVIDIA_CAPS }}`      | Override the default NVIDIA_CAPS for the container, each entry is a string    |

> Environment variables in `fixedEnv` will be scanned for duplicate keys
> between other secrets/configmaps/env/envList and will throw an error if it finds any.

---

Notes:

By default it will set the following environment variables:

- TZ: `{{ .Values.TZ }}` (or the value set in the container level under `fixedEnv`)
- UMASK: `{{ .Values.securityContext.container.UMASK }}` (or the value set in the container level under `fixedEnv`)
- UMASK_SET: `{{ .Values.securityContext.container.UMASK }}` (or the value set in the container level under `fixedEnv`)
- S6_READ_ONLY_ROOT: `1` (Only when `readOnlyRootFilesystem` or `runAsNonRoot` is `true`)
- PUID, USER_ID, UID: `{{ .Values.securityContext.container.PUID }}` (or the value set in the container level under `fixedEnv`)
  - Only when `runAsUser` or `runAsGroup` is `0`
- PGID, GROUP_ID, GID: To the `fsGroup` set for the pod (Either the default or the overridden value)
  - Only when `runAsUser` or `runAsGroup` is `0`
- NVIDIA_DRIVER_CAPABILITIES: `{{ .Values.resources.NVIDIA_CAPS }}` (or the value set in the container level under `fixedEnv`)
  - Only when `scaleGPU` is assigned to the container

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].fixedEnv`

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
          fixedEnv:
            TZ: "America/New_York"
            NVIDIA_CAPS:
              - compute
            UMASK: "003"
            PUID: "0"
```
