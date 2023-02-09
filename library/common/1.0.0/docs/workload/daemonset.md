# DaemonSet

| Key                                                   |   Type   | Required | Helm Template |     Default     | Description                                                          |
| :---------------------------------------------------- | :------: | :------: | :-----------: | :-------------: | :------------------------------------------------------------------- |
| workload.[workload-name].strategy                     | `string` |    ❌    |      ❌       | `RollingUpdate` | Define the strategy of the workload (OnDelete, RollingUpdate)        |
| workload.[workload-name].rollingUpdate                |  `dict`  |    ❌    |      ❌       |      `{}`       | Holds the rollingUpdate options, Only when strategy is RollingUpdate |
| workload.[workload-name].rollingUpdate.maxUnavailable |  `int`   |    ❌    |      ❌       |                 | Define the maxUnavailable, Only when strategy is RollingUpdate       |
| workload.[workload-name].rollingUpdate.maxSurge       |  `int`   |    ❌    |      ❌       |                 | Define the maxSurge, Only when strategy is RollingUpdate             |

---

Notes:

View common `keys` of `workload` in [workload Documentation](workload.md).

> Value of `workload.[workload-name].podSpec.restartPolicy` can only be `Always` for this type of workload

---

Examples:

```yaml
workload:
  workload-name:
    enabled: true
    primary: true
    type: DaemonSet
    replicas: 1
    revisionHistoryLimit: 3
    strategy: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
    podSpec: {}

  other-workload-name:
    enabled: true
    primary: false
    type: DaemonSet
    labels: {}
    annotations: {}
    replicas: 1
    revisionHistoryLimit: 3
    strategy: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
    podSpec: {}
```
