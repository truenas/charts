# Job

| Key                                                   |   Type   | Required | Helm Template |   Default    | Description                                     |
| :---------------------------------------------------- | :------: | :------: | :-----------: | :----------: | :---------------------------------------------- |
| controllers.[controller-name].completionMode          | `string` |    ❌    |      ❌       | `NonIndexed` | Define the completionMode (Indexed, NonIndexed) |
| controllers.[controller-name].backoffLimit            |  `int`   |    ❌    |      ❌       |     `5`      | Define the backoffLimit                         |
| controllers.[controller-name].completions             |  `int`   |    ❌    |      ❌       |              | Define the completions                          |
| controllers.[controller-name].parallelism             |  `int`   |    ❌    |      ❌       |     `1`      | Define the parallelism                          |
| controllers.[controller-name].ttlSecondsAfterFinished |  `int`   |    ❌    |      ❌       |    `120`     | Define the ttlSecondsAfterFinished              |
| controllers.[controller-name].activeDeadlineSeconds   |  `int`   |    ❌    |      ❌       |              | Define the activeDeadlineSeconds                |

---

Notes:

View common `keys` of `controllers` in [Controllers Documentation](controllers.md).

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
    podSpec:
      labels: {}
      annotations: {}
      hostNetwork: false
      enableServiceLinks: false
      restartPolicy: Never

  other-controller-name:
    enabled: true
    primary: false
    type: Job
    labels: {}
    annotations: {}
    podSpec: {}
```
