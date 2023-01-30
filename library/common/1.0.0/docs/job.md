# Job

| Key                                                   |   Type    | Required | Helm Template |   Default    | Description                                     |
| :---------------------------------------------------- | :-------: | :------: | :-----------: | :----------: | :---------------------------------------------- |
| controllers                                           |  `dict`   |    ❌    |      ❌       |     `{}`     | Define the controllers as dicts                 |
| controllers.[controller-name]                         |  `dict`   |    ✅    |      ❌       |     `{}`     | Holds controller definition                     |
| controllers.[controller-name].enabled                 | `boolean` |    ✅    |      ❌       |   `false`    | Enables or Disables the controller              |
| controllers.[controller-name].primary                 | `boolean` |    ✅    |      ❌       |   `false`    | Sets the controller as primary                  |
| controllers.[controller-name].labels                  |  `dict`   |    ❌    |      ✅       |     `{}`     | Additional labels for controller                |
| controllers.[controller-name].annotations             |  `dict`   |    ❌    |      ✅       |     `{}`     | Additional annotations for controller           |
| controllers.[controller-name].type                    | `string`  |    ✅    |      ❌       |     `""`     | Define the type (kind) of the controller        |
| controllers.[controller-name].completionMode          | `string`  |    ❌    |      ❌       | `NonIndexed` | Define the completionMode (Indexed, NonIndexed) |
| controllers.[controller-name].backoffLimit            |   `int`   |    ❌    |      ❌       |     `5`      | Define the backoffLimit                         |
| controllers.[controller-name].completions             |   `int`   |    ❌    |      ❌       |              | Define the completions                          |
| controllers.[controller-name].parallelism             |   `int`   |    ❌    |      ❌       |     `1`      | Define the parallelism                          |
| controllers.[controller-name].ttlSecondsAfterFinished |   `int`   |    ❌    |      ❌       |    `120`     | Define the ttlSecondsAfterFinished              |
| controllers.[controller-name].activeDeadlineSeconds   |   `int`   |    ❌    |      ❌       |              | Define the activeDeadlineSeconds                |

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
    type: Job
    labels: {}
    annotations: {}
    backoffLimit: 5
    completionMode: Indexed
    completions: 5
    parallelism: 5
    ttlSecondsAfterFinished: 100
    activeDeadlineSeconds: 100
  other-controller-name:
    enabled: true
    primary: false
    type: Job
    labels: {}
    annotations: {}
```
