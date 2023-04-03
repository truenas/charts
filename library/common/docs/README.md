# Common Chart Documentation

## Global and Defaults

This options should not need to be changed per chart.

| Key                                                                |   Type   | Required |   Helm Template    |   Default   | Description                                                  |
| :----------------------------------------------------------------- | :------: | :------: | :----------------: | :---------: | :----------------------------------------------------------- |
| .Values.global.labels                                              |  `dict`  |    ❌    | ✅ (On value only) |    `{}`     | Additional Labels that apply to all objects                  |
| .Values.global.annotations                                         |  `dict`  |    ❌    | ✅ (On value only) |    `{}`     | Additional Annotations that apply to all objects             |
| .Values.global.minNodePort                                         |  `int`   |    ✅    |         ❌         |   `9000`    | Minimum Node Port Allowed                                    |
| .Values.fallbackDefaults.probeType                                 | `string` |    ✅    |         ❌         |   `http`    | Default probe type when not defined in the container level   |
| .Values.fallbackDefaults.serviceProtocol                           | `string` |    ✅    |         ❌         |    `tcp`    | Default service protocol when not defined in the service     |
| .Values.fallbackDefaults.serviceType                               | `string` |    ✅    |         ❌         | `ClusterIP` | Default service type when not defined in the service         |
| .Values.fallbackDefaults.persistenceType                           | `string` |    ✅    |         ❌         | `emptyDir`  | Default persistence type when not defined in the persistence |
| .Values.fallbackDefaults.probeTimeouts                             |  `dict`  |    ✅    |         ❌         |  See below  | Default probe timeouts if not defined in the container       |
| .Values.fallbackDefaults.probeTimeouts.[probe]                     |  `dict`  |    ✅    |         ❌         |  See below  | Default probe timeouts if not defined in the container       |
| .Values.fallbackDefaults.probeTimeouts.[probe].initialDelaySeconds |  `int`   |    ✅    |         ❌         |  See below  | Default initialDelaySeconds if not defined in the container  |
| .Values.fallbackDefaults.probeTimeouts.[probe].periodSeconds       |  `int`   |    ✅    |         ❌         |  See below  | Default periodSeconds if not defined in the container        |
| .Values.fallbackDefaults.probeTimeouts.[probe].timeoutSeconds      |  `int`   |    ✅    |         ❌         |  See below  | Default timeoutSeconds if not defined in the container       |
| .Values.fallbackDefaults.probeTimeouts.[probe].failureThreshold    |  `int`   |    ✅    |         ❌         |  See below  | Default failureThreshold if not defined in the container     |
| .Values.fallbackDefaults.probeTimeouts.[probe].successThreshold    |  `int`   |    ✅    |         ❌         |  See below  | Default successThreshold if not defined in the container     |

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
```

---

## Global Values that apply on pods/containers

All of the below values are applied on all pods/containers, but can be overridden on the pod/container level.
This is so, you can have a single point to define the values from the scale UI,
but still have the ability to override them on the pod/container level, in case you need to.

| Key                                              |   Type    | Required | Helm Template |  Default  | Description                                                            |
| :----------------------------------------------- | :-------: | :------: | :-----------: | :-------: | :--------------------------------------------------------------------- |
| .Values.TZ                                       | `string`  |    ✅    |      ❌       | See below | Timezone that is used everywhere applicable                            |
| .Values.resources                                |  `dict`   |    ✅    |      ❌       | See below | Resources                                                              |
| .Values.resources.limits                         |  `dict`   |    ✅    |      ❌       | See below | Resources                                                              |
| .Values.resources.limits.cpu                     | `string`  |    ✅    |      ❌       | See below | Resources                                                              |
| .Values.resources.limits.memory                  | `string`  |    ✅    |      ❌       | See below | Resources                                                              |
| .Values.resources.requests                       |  `dict`   |    ✅    |      ❌       | See below | Resources                                                              |
| .Values.resources.requests.cpu                   | `string`  |    ✅    |      ❌       | See below | Resources                                                              |
| .Values.resources.requests.memory                | `string`  |    ✅    |      ❌       | See below | Resources                                                              |
| .Values.resources.NVIDIA_CAPS                    |  `list`   |    ✅    |      ❌       | See below | NVIDIA_CAPS (Only applied when scaleGPU is passed)                     |
| .Values.podOptions                               |  `dict`   |    ✅    |      ❌       | See below | Options that apply to all pods                                         |
| .Values.podOptions.enableServiceLinks            | `boolean` |    ✅    |      ❌       | See below | enableServiceLinks                                                     |
| .Values.podOptions.hostNetwork                   | `boolean` |    ✅    |      ❌       | See below | hostNetwork                                                            |
| .Values.podOptions.restartPolicy                 | `string`  |    ✅    |      ❌       | See below | restartPolicy                                                          |
| .Values.podOptions.dnsPolicy                     | `string`  |    ✅    |      ❌       | See below | dnsPolicy                                                              |
| .Values.podOptions.dnsConfig                     |  `list`   |    ✅    |      ❌       | See below | dnsConfig                                                              |
| .Values.podOptions.hostAliases                   |  `list`   |    ✅    |      ❌       | See below | hostAliases                                                            |
| .Values.podOptions.tolerations                   |  `list`   |    ✅    |      ❌       | See below | tolerations                                                            |
| .Values.podOptions.runtimeClassName              | `string`  |    ✅    |      ❌       | See below | runtimeClassName (value in ixChartContext will always take precedence) |
| .Values.podOptions.automountServiceAccountToken  | `boolean` |    ✅    |      ❌       | See below | automountServiceAccountToken                                           |
| .Values.podOptions.terminationGracePeriodSeconds |   `int`   |    ✅    |      ❌       | See below | terminationGracePeriodSeconds                                          |

<!-- TODO: Improve descriptions -->

---

Defaults:

```yaml
TZ: UTC
resources:
  limits:
    cpu: 4000m
    memory: 8Gi
  requests:
    cpu: 10m
    memory: 50Mi
  NVIDIA_CAPS:
    - all
podOptions:
  enableServiceLinks: false
  hostNetwork: false
  restartPolicy: Always
  dnsPolicy: ClusterFirst
  dnsConfig:
    options:
      - name: ndots
        value: "2"
  hostAliases: []
  tolerations: []
  runtimeClassName: ""
  automountServiceAccountToken: false
  terminationGracePeriodSeconds: 30
```

---

## Global Security Context

All of the below values are applied on all pods/containers, but can be overridden on the pod/container level.
This is so, you can have a single point to define the values from the scale UI,
but still have the ability to override them on the pod/container level, in case you need to.

| Key                                                        |   Type    | Required | Helm Template |  Default  | Description                              |
| :--------------------------------------------------------- | :-------: | :------: | :-----------: | :-------: | :--------------------------------------- |
| .Values.securityContext                                    |  `dict`   |    ✅    |      ❌       | See below | Security Context                         |
| .Values.securityContext.container                          |  `dict`   |    ✅    |      ❌       | See below | Security Context for containers          |
| .Values.securityContext.container.PUID                     |   `int`   |    ✅    |      ❌       | See below | PUID (Only applied when running as root) |
| .Values.securityContext.container.UMASK                    | `string`  |    ✅    |      ❌       | See below | UMASK                                    |
| .Values.securityContext.container.runAsNonRoot             | `boolean` |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.runAsUser                |   `int`   |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.runAsGroup               |   `int`   |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.readOnlyRootFilesystem   | `boolean` |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.allowPrivilegeEscalation | `boolean` |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.privileged               | `boolean` |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.seccompProfile           |  `dict`   |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.seccompProfile.type      | `string`  |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.seccompProfile.profile   | `string`  |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.capabilities             |  `dict`   |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.capabilities.add         |  `list`   |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.container.capabilities.drop        |  `list`   |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.pod                                |  `dict`   |    ✅    |      ❌       | See below | Security Context for pods                |
| .Values.securityContext.pod.fsGroup                        |   `int`   |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.pod.fsGroupChangePolicy            | `string`  |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.pod.supplementalGroup              |  `list`   |    ✅    |      ❌       | See below |                                          |
| .Values.securityContext.pod.sysctls                        |  `list`   |    ✅    |      ❌       | See below |                                          |

<!-- TODO: Improve descriptions -->

Defaults:

```yaml
securityContext:
  # -- Container security context for all containers
  # Can be overruled per container
  container:
    PUID: 568
    UMASK: "002"
    runAsNonRoot: true
    runAsUser: 568
    runAsGroup: 568
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    privileged: false
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      add: []
      drop:
        - ALL
  # -- Pod security context for all pods
  # Can be overruled per pod
  pod:
    fsGroup: 568
    fsGroupChangePolicy: OnRootMismatch
    supplementalGroups: []
    sysctls: []
```

---

## Images

| Key                      |   Type   | Required | Helm Template |  Default  | Description       |
| :----------------------- | :------: | :------: | :-----------: | :-------: | :---------------- |
| .Values.image            |  `dict`  |    ✅    |      ❌       | See below | Image             |
| .Values.image.repository | `string` |    ✅    |      ❌       | See below | Image Repository  |
| .Values.image.tag        | `string` |    ✅    |      ❌       | See below | Image Tag         |
| .Values.image.pullPolicy | `string` |    ✅    |      ❌       | See below | Image Pull Policy |

<!-- TODO: Improve descriptions -->

---

Defaults:

```yaml
image:
  repository: ""
  tag: ""
  pullPolicy: IfNotPresent
```

You can define additional images using the following convention:

```yaml
workerImage:
  repository: ""
  tag: ""
  pullPolicy: IfNotPresent
```

There isn't anything special in the above format (`nameImage`), it's just a convention.
It's also a format that some external tools can use for automatic image updates.
For example, [Renovate](https://docs.renovatebot.com/modules/manager/helm-values/#additional-information)

---

Additional Documentation:

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
