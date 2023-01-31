# DaemonSet

| Key                                                        |   Type    | Required | Helm Template |                        Default                        | Description                                                                 |
| :--------------------------------------------------------- | :-------: | :------: | :-----------: | :---------------------------------------------------: | :-------------------------------------------------------------------------- |
| controllers.[controller-name].strategy                     | `string`  |    ❌    |      ❌       |                    `RollingUpdate`                    | Define the strategy of the controller (OnDelete, RollingUpdate)             |
| controllers.[controller-name].rollingUpdate                |  `dict`   |    ❌    |      ❌       |                         `{}`                          | Holds the rollingUpdate options, Only when strategy is RollingUpdate        |
| controllers.[controller-name].rollingUpdate.maxUnavailable |   `int`   |    ❌    |      ❌       |                                                       | Define the maxUnavailable, Only when strategy is RollingUpdate              |
| controllers.[controller-name].rollingUpdate.partition      |   `int`   |    ❌    |      ❌       |                                                       | Define the partition, Only when strategy is RollingUpdate                   |

---

Notes:

View common `keys` of `controllers` in [Controllers Documentation](controllers.md).

> Value of `controllers.[controller-name].podSpec.restartPolicy` can only be `Always` for this type of controller

---

Examples:

```yaml
controllers:
  controller-name:
    enabled: true
    primary: true
    type: StatefulSet
    replicas: 1
    revisionHistoryLimit: 3
    strategy: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      partition: 1
    podSpec: {}

  other-controller-name:
    enabled: true
    primary: false
    type: StatefulSet
    replicas: 1
    revisionHistoryLimit: 3
    strategy: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      partition: 1
    podSpec: {}
```
