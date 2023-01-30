# Deployment

| Key                                                        |   Type    | Required | Helm Template |  Default   | Description                                                          |
| :--------------------------------------------------------- | :-------: | :------: | :-----------: | :--------: | :------------------------------------------------------------------- |
| controllers                                                |  `dict`   |    ❌    |      ❌       |    `{}`    | Define the controllers as dicts                                      |
| controllers.[controller-name]                              |  `dict`   |    ✅    |      ❌       |    `{}`    | Holds controller definition                                          |
| controllers.[controller-name].enabled                      | `boolean` |    ✅    |      ❌       |  `false`   | Enables or Disables the controller                                   |
| controllers.[controller-name].primary                      | `boolean` |    ✅    |      ❌       |  `false`   | Sets the controller as primary                                       |
| controllers.[controller-name].labels                       |  `dict`   |    ❌    |      ✅       |    `{}`    | Additional labels for controller                                     |
| controllers.[controller-name].annotations                  |  `dict`   |    ❌    |      ✅       |    `{}`    | Additional annotations for controller                                |
| controllers.[controller-name].type                         | `string`  |    ✅    |      ❌       |    `""`    | Define the type (kind) of the controller                             |
| controllers.[controller-name].strategy                     | `string`  |    ❌    |      ❌       | `Recreate` | Define the strategy of the controller (Recreate, RollingUpdate)      |
| controllers.[controller-name].rollingUpdate                |  `dict`   |    ❌    |      ❌       |    `{}`    | Holds the rollingUpdate options, Only when strategy is RollingUpdate |
| controllers.[controller-name].rollingUpdate.maxUnavailable |   `int`   |    ❌    |      ❌       |            | Define the maxUnavailable, Only when strategy is RollingUpdate       |
| controllers.[controller-name].rollingUpdate.maxSurge       |   `int`   |    ❌    |      ❌       |            | Define the maxSurge, Only when strategy is RollingUpdate             |

---

Appears in:

- `.Values.controllers`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$ControllerName` (release-name-chart-name-controller-name)

---

Examples:

```yaml
controllers:
  controller-name:
    enabled: true
    primary: true
    type: Deployment
    labels: {}
    annotations: {}
    replicas: 1
    revisionHistoryLimit: 3
    strategy: Recreate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  other-controller-name:
    enabled: true
    primary: false
    type: Deployment
    labels: {}
    annotations: {}
    replicas: 1
    revisionHistoryLimit: 3
    strategy: Recreate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```
