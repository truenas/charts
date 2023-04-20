# workload

| Key                                                                  |   Type    | Required |   Helm Template    |                             Default                             | Description                                                              |
| :------------------------------------------------------------------- | :-------: | :------: | :----------------: | :-------------------------------------------------------------: | :----------------------------------------------------------------------- |
| workload                                                             |  `dict`   |    ❌    |         ❌         |                              `{}`                               | Define the workload as dicts                                             |
| workload.[workload-name]                                             |  `dict`   |    ✅    |         ❌         |                              `{}`                               | Holds workload definition                                                |
| workload.[workload-name].enabled                                     | `boolean` |    ✅    |         ❌         |                             `false`                             | Enables or Disables the workload                                         |
| workload.[workload-name].primary                                     | `boolean` |    ✅    |         ❌         |                             `false`                             | Sets the workload as primary                                             |
| workload.[workload-name].labels                                      |  `dict`   |    ❌    | ✅ (On value only) |                              `{}`                               | Additional labels for workload                                           |
| workload.[workload-name].annotations                                 |  `dict`   |    ❌    | ✅ (On value only) |                              `{}`                               | Additional annotations for workload                                      |
| workload.[workload-name].type                                        | `string`  |    ✅    |         ❌         |                              `""`                               | Define the kind of the workload (Deployment, CronJob, Job)               |
| workload.[workload-name].podSpec                                     |  `dict`   |    ✅    |         ❌         |                              `{}`                               | Holds the pod definition                                                 |
| workload.[workload-name].podSpec.labels                              |  `dict`   |    ❌    | ✅ (On value only) |                              `{}`                               | Additional Pod Labels                                                    |
| workload.[workload-name].podSpec.annotations                         |  `dict`   |    ❌    | ✅ (On value only) |                              `{}`                               | Pod Annotations                                                          |
| workload.[workload-name].podSpec.automountServiceAccountToken        | `boolean` |    ❌    |         ❌         | `{{ .Values.podOptions.automountServiceAccoutnToken }}` (false) | Pod's automountServiceAccountToken                                       |
| workload.[workload-name].podSpec.hostNetwork                         | `boolean` |    ❌    |         ❌         |         `{{ .Values.podOptions.hostNetwork }}` (false)          | Pod's hostNetwork                                                        |
| workload.[workload-name].podSpec.enableServiceLinks                  | `boolean` |    ❌    |         ❌         |      `{{ .Values.podOptions.enableServiceLinks }}` (false)      | Pod's enableServiceLinks                                                 |
| workload.[workload-name].podSpec.restartPolicy                       | `string`  |    ❌    |         ✅         |        `{{ .Values.podOptions.restartPolicy }}` (Always)        | Pod's restartPolicy. (Always, Never, OnFailure)                          |
| workload.[workload-name].podSpec.hostname                            | `string`  |    ❌    |         ✅         |                              `""`                               | Pod's hostname                                                           |
| workload.[workload-name].podSpec.terminationGracePeriodSeconds       |   `int`   |    ❌    |         ✅         | `{{ .Values.podOptions.terminationGracePeriodSeconds }}` (120)  | Pod's terminationGracePeriodSeconds                                      |
| workload.[workload-name].podSpec.hostAliases                         |  `list`   |    ❌    |         ❌         |                                                                 | Pod's host aliases                                                       |
| workload.[workload-name].podSpec.hostAliases.ip                      | `string`  |    ❌    |         ✅         |                                                                 | Value for `ip` in hosts aliases                                          |
| workload.[workload-name].podSpec.hostAliases.hostnames               |  `list`   |    ❌    |         ❌         |                                                                 | Hostnames for the `ip` in hosts aliases                                  |
| workload.[workload-name].podSpec.hostAliases.hostnames.[host-name]   | `string`  |    ❌    |         ✅         |                                                                 | [Value] for `hostnames` for the `ip` in hosts aliases                    |
| workload.[workload-name].podSpec.dnsPolicy                           | `string`  |    ❌    |         ✅         |       `{{ .Values.podOptions.dnsPolicy }}` (ClusterFirst)       | Pod's DNS Policy (ClusterFirst, ClusterFirstWithHostNet, Default, None). |
| workload.[workload-name].podSpec.dnsConfig                           |  `dict`   |    ❌    |         ❌         |              `{{ .Values.podOptions.dnsConfig }}`               | Pod's DNS Config                                                         |
| workload.[workload-name].podSpec.dnsConfig.nameservers               |  `list`   |    ❌    |         ✅         |                              `[]`                               | Pod's DNS Config - Nameservers (Max 3)                                   |
| workload.[workload-name].podSpec.dnsConfig.nameservers.nameserver    | `string`  |    ✅    |         ✅         |                              `""`                               | Pod's DNS Config - Nameserver                                            |
| workload.[workload-name].podSpec.dnsConfig.searches                  |  `list`   |    ❌    |         ✅         |                              `[]`                               | Pod's DNS Config - Searches (Max 6)                                      |
| workload.[workload-name].podSpec.dnsConfig.searches.[search]         | `string`  |    ✅    |         ✅         |                              `""`                               | Pod's DNS Config - Search                                                |
| workload.[workload-name].podSpec.dnsConfig.options                   |  `dict`   |    ❌    |         ❌         |                              `{}`                               | Pod's DNS Config - Options                                               |
| workload.[workload-name].podSpec.dnsConfig.options.name              | `string`  |    ✅    |         ✅         |                              `""`                               | Pod's DNS Config - Option name                                           |
| workload.[workload-name].podSpec.dnsConfig.options.value             | `string`  |    ❌    |         ✅         |                              `""`                               | Pod's DNS Config - Option value                                          |
| workload.[workload-name].podSpec.tolerations                         |  `list`   |    ❌    |         ❌         |           `{{ .Values.podOptions.tolerations }}` ([])           | Pod's Tolerations                                                        |
| workload.[workload-name].podSpec.tolerations.operator                | `string`  |    ✅    |         ✅         |                                                                 | Toleration's `operator` (Equal, Exists)                                  |
| workload.[workload-name].podSpec.tolerations.key                     | `string`  |  ❌/✅   |         ✅         |                                                                 | Toleration's `key`. Required only when `operator` = `Equal`              |
| workload.[workload-name].podSpec.tolerations.value                   | `string`  |  ❌/✅   |         ✅         |                                                                 | Toleration's `value`. Required only when `operator` = `Equal`            |
| workload.[workload-name].podSpec.tolerations.effect                  | `string`  |    ❌    |         ✅         |                                                                 | Toleration's `effect`.(NoExecute, NoSchedule, PreferNoSchedule)          |
| workload.[workload-name].podSpec.tolerations.tolerationSeconds       |   `int`   |    ❌    |         ❌         |                                                                 | Toleration's `tolerationSeconds`.                                        |
| workload.[workload-name].podSpec.runtimeClassName                    | `string`  |    ❌    |         ✅         |        `{{ .Values.podOptions.runtimeClassName }}` ("")         | Pod's runtimeClassName                                                   |
| workload.[workload-name].podSpec.securityContext                     |  `dict`   |    ❌    |         ❌         |               `{{ .Values.securityContext.pod }}`               | Pod's securityContext                                                    |
| workload.[workload-name].podSpec.securityContext.fsGroup             |   `int`   |    ❌    |         ❌         |                              `568`                              | Pod's fsGroup                                                            |
| workload.[workload-name].podSpec.securityContext.fsGroupChangePolicy | `string`  |    ❌    |         ❌         |                        `OnRootMismatch`                         | Pod's fsGroupChangePolicy (Always, OnRootMismatch)                       |
| workload.[workload-name].podSpec.securityContext.supplementalGroups  |  `list`   |    ❌    |         ❌         |                              `[]`                               | Pod's supplementalGroups (list of `int`)                                 |
| workload.[workload-name].podSpec.securityContext.sysctls             |  `list`   |    ❌    |         ❌         |                              `[]`                               | Pod's sysctls                                                            |
| workload.[workload-name].podSpec.securityContext.sysctls.name        | `string`  |    ✅    |         ✅         |                              `""`                               | `name` of the sysctl                                                     |
| workload.[workload-name].podSpec.securityContext.sysctls.value       | `string`  |    ✅    |         ✅         |                              `""`                               | `value` of the sysctl                                                    |
| workload.[workload-name].podSpec.containers                          |  `dict`   |    ❌    |         ❌         |                              `{}`                               | Define container(s)                                                      |
| workload.[workload-name].podSpec.initContainers                      |  `dict`   |    ❌    |         ❌         |                              `{}`                               | Define initContainer(s)                                                  |

---

Notes

> `dnsPolicy` is set automatically to `ClusterFirstWithHostNet` when `hostNetwork` is `true` > `runtimeClassName` will ignore any value set and use the `.Values.global.ixChartContext.nvidiaRuntimeClassName`,
> if a GPU is assigned to a container and Scale Middleware sets `.Values.global.ixChartContext.addNvidiaRuntimeClass` to `true`.
> Note that it will only set the `runtimeClassName` on the pod that this container belongs to.
> **sysctl** `net.ipv4.ip_unprivileged_port_start` will be automatically set to the lowest `targetPort` (or `port` if targetPort is not defined) number assigned to the pod.
> **sysctl** `net.ipv4.ping_group_range` will be automatically set to the lowest and highest `targetPort` (or `port` if targetPort is not defined) number assigned to the pod.

---

Appears in:

- `.Values.workload`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$WorkloadName` (release-name-chart-name-workload-name)

---

> Those are the common `keys` for all **workloads**.
> Additional keys, information and examples, see on the specific kind of workload

- [Deployment](deployment.md)
- [CronJob](cronjob.md)
- [Job](job.md)

> Additional keys, information and examples for `workload.[workload-name].podSpec.containers`.

- [Container](../container/README.md)
- [InitContainer](../container/README.md#initcontainer)

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
      labels:
        key: value
      annotations:
        key: value
      automountServiceAccountToken: true
      hostNetwork: false
      enableServiceLinks: false
      hostname: some-hostname
      terminationGracePeriodSeconds: 100
      hostAliases:
        - ip: 10.10.10.100
          hostnames:
            - myserver.local
            - storage.local
        - ip: 10.10.10.101
          hostnames:
            - myotherserver.local
            - backups.local
      dnsPolicy: ClusterFirst
      dnsConfig:
        nameservers:
          - 1.1.1.1
          - 1.0.0.1
        searches:
          - ns1.svc.cluster-domain.example
          - my.dns.search.suffix
        options:
          - name: ndots
            value: "2"
          - name: edns0
      tolerations:
        - operator: Exists
          effect: NoExecute
          tolerationSeconds: 3600
      runtimeClassName: some-runtime-class
      securityContext:
        fsGroup: 568
        fsGroupChangePolicy: OnRootMismatch
        supplementalGroups:
          - 568
        sysctls:
          - name: net.ipv4.ip_local_port_range
            value: 1024 65535
```
