# CronJob

| Key                                                 |   Type   | Required | Helm Template |         Default          | Description                                           |
| :-------------------------------------------------- | :------: | :------: | :-----------: | :----------------------: | :---------------------------------------------------- |
| workload.[workload-name].schedule                   | `string` |    ✅    |      ✅       |           `""`           | Define the schedule                                   |
| workload.[workload-name].timezone                   | `string` |    ❌    |      ✅       | `{{ .Values.TZ }}` | Define the timezone                                   |
| workload.[workload-name].concurrencyPolicy          | `string` |    ❌    |      ✅       |         `Forbid`         | Define the concurrencyPolicy (Allow, Replace, Forbid) |
| workload.[workload-name].failedJobsHistoryLimit     |  `int`   |    ❌    |      ❌       |           `1`            | Define the failedJobsHistoryLimit                     |
| workload.[workload-name].successfulJobsHistoryLimit |  `int`   |    ❌    |      ❌       |           `3`            | Define the successfulJobsHistoryLimit                 |
| workload.[workload-name].startingDeadlineSeconds    |  `int`   |    ❌    |      ❌       |                          | Define the startingDeadlineSeconds                    |
| workload.[workload-name].completionMode             | `string` |    ❌    |      ❌       |       `NonIndexed`       | Define the completionMode (Indexed, NonIndexed)       |
| workload.[workload-name].backoffLimit               |  `int`   |    ❌    |      ❌       |           `5`            | Define the backoffLimit                               |
| workload.[workload-name].completions                |  `int`   |    ❌    |      ❌       |                          | Define the completions                                |
| workload.[workload-name].parallelism                |  `int`   |    ❌    |      ❌       |           `1`            | Define the parallelism                                |
| workload.[workload-name].ttlSecondsAfterFinished    |  `int`   |    ❌    |      ❌       |          `120`           | Define the ttlSecondsAfterFinished                    |
| workload.[workload-name].activeDeadlineSeconds      |  `int`   |    ❌    |      ❌       |                          | Define the activeDeadlineSeconds                      |

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
    type: CronJob
    schedule: "{{ .Values.cron }}"
    timezone: "{{ .Values.someTimezone }}"
    concurrencyPolicy: Allow
    failedJobsHistoryLimit: 2
    successfulJobsHistoryLimit: 4
    startingDeadlineSeconds: 100
    backoffLimit: 5
    completionMode: Indexed
    completions: 5
    parallelism: 5
    ttlSecondsAfterFinished: 100
    activeDeadlineSeconds: 100
    podSpec:
      restartPolicy: OnFailure

  other-workload-name:
    enabled: true
    primary: false
    type: CronJob
    schedule: "* * * * *"
    podSpec: {}
```
