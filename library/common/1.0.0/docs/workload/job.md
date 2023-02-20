# Job

| Key                                              |   Type   | Required | Helm Template |   Default    | Description                                     |
| :----------------------------------------------- | :------: | :------: | :-----------: | :----------: | :---------------------------------------------- |
| workload.[workload-name].completionMode          | `string` |    ❌    |      ❌       | `NonIndexed` | Define the completionMode (Indexed, NonIndexed) |
| workload.[workload-name].backoffLimit            |  `int`   |    ❌    |      ❌       |     `5`      | Define the backoffLimit                         |
| workload.[workload-name].completions             |  `int`   |    ❌    |      ❌       |              | Define the completions                          |
| workload.[workload-name].parallelism             |  `int`   |    ❌    |      ❌       |     `1`      | Define the parallelism                          |
| workload.[workload-name].ttlSecondsAfterFinished |  `int`   |    ❌    |      ❌       |    `120`     | Define the ttlSecondsAfterFinished              |
| workload.[workload-name].activeDeadlineSeconds   |  `int`   |    ❌    |      ❌       |              | Define the activeDeadlineSeconds                |

---

Notes:

View common `keys` of `workload` in [workload Documentation](workload.md).

---

Examples:

```yaml
workload:
  workload-name:
    enabled: true
    primary: true
    type: Job
    backoffLimit: 5
    completionMode: Indexed
    completions: 5
    parallelism: 5
    ttlSecondsAfterFinished: 100
    activeDeadlineSeconds: 100
    podSpec:
      restartPolicy: Never

  other-workload-name:
    enabled: true
    primary: false
    type: Job
    podSpec: {}
```
