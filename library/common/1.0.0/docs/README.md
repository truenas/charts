# Root Chart Context

| Key                                                                |   Type   | Required |   Helm Template    |   Default   | Description                                                  |
| :----------------------------------------------------------------- | :------: | :------: | :----------------: | :---------: | :----------------------------------------------------------- |
| .Values.TZ                                                         | `string` |    ✅    |         ❌         |    `UTC`    | Timezone that is used everywhere applicable                  |
| .Values.global.labels                                              |  `dict`  |    ❌    | ✅ (On value only) |    `{}`     | Additional Labels that apply to all objects                  |
| .Values.global.annotations                                         |  `dict`  |    ❌    | ✅ (On value only) |    `{}`     | Additional Annotations that apply to all objects             |
| .Values.global.minNodePort                                         |  `int`   |    ✅    |         ❌         |   `9000`    | Minimum Node Port Allowed                                    |
| .Values.fallbackDefaults.probeType                                 | `string` |    ✅    |         ❌         |   `http`    | Default probe type when not defined in the container level   |
| .Values.fallbackDefaults.serviceProtocol                           | `string` |    ✅    |         ❌         |    `tcp`    | Default service protocol when not defined in the service     |
| .Values.fallbackDefaults.serviceType                               | `string` |    ✅    |         ❌         | `ClusterIP` | Default service type when not defined in the service         |
| .Values.fallbackDefaults.persistenceType                           | `string` |    ✅    |         ❌         | `emptyDir`  | Default persistence type when not defined in the persistence |
| .Values.fallbackDefaults.probeTimeouts                             |  `dict`  |    ✅    |         ❌         |  See below  | Default probe timeouts if not defined in the container       |
| .Values.fallbackDefaults.probeTimeouts.[probe]                     |  `dict`  |    ✅    |         ❌         |  See below  | Default probe timeouts if not defined in the container       |
| .Values.fallbackDefaults.probeTimeouts.[probe].initialDelaySeconds |  `int`   |    ✅    |         ❌         |  See below  | Default initialDelaySeconds if not defined in the container       |
| .Values.fallbackDefaults.probeTimeouts.[probe].periodSeconds       |  `int`   |    ✅    |         ❌         |  See below  | Default periodSeconds if not defined in the container       |
| .Values.fallbackDefaults.probeTimeouts.[probe].timeoutSeconds      |  `int`   |    ✅    |         ❌         |  See below  | Default timeoutSeconds if not defined in the container       |
| .Values.fallbackDefaults.probeTimeouts.[probe].failureThreshold    |  `int`   |    ✅    |         ❌         |  See below  | Default failureThreshold if not defined in the container       |
| .Values.fallbackDefaults.probeTimeouts.[probe].successThreshold    |  `int`   |    ✅    |         ❌         |  See below  | Default successThreshold if not defined in the container       |

---

Default probe timeouts:

```yaml
probeTimeouts:
  liveness:
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 5
    successThreshold: 1
  readiness:
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 5
    successThreshold: 2
  startup:
    initialDelaySeconds: 10
    periodSeconds: 5
    timeoutSeconds: 2
    failureThreshold: 60
    successThreshold: 1
```

---

Examples:

```yaml
global:
  labels:
    key: value
    keytpl: "{{ .Values.some.value }}"
  annotations:
    key: value
    keytpl: "{{ .Values.some.value }}"
  minNodePort: 9000

faillbackDefaults:
  probeType: http
  serviceProtocol: tcp
  serviceType: ClusterIP
  persistenceType: emptyDir
  probeTimeouts:
    liveness:
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 5
      successThreshold: 1
    readiness:
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 5
      successThreshold: 2
    startup:
      initialDelaySeconds: 10
      periodSeconds: 5
      timeoutSeconds: 2
      failureThreshold: 60
      successThreshold: 1

TZ: Europe/Berlin
```

---

Documentation:

- [workload](workload/README.md)
- [container](container/README.md)
- [service](service/README.md)
- [persistence](persistence/README.md)
- [configmap](configmap.md)
- [secret](secret.md)
- [imagePullSecrets](imagePullSecrets.md)
- [serviceAccount](serviceAccount.md)
- [rbac](rbac.md)
- [scaleGPU](scaleGPU.md)
- [scaleCertificate](scaleCertificate.md)
- [scaleExternalInterface](scaleExternalInterface.md)
- [notes](notes.md)

---

Notes:

This applies across all the documentation:

- Helm Template:
  - `❌` means that the value is not templated
  - `✅` means that the value is templated,
    for example instead of a hardcoded value, you can set it to `{{ .Values.some.value }}`.
    and it will be replaced by the value contained in `.Values.some.value` at the installation/upgrade time.
