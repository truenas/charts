# CronJob

| Key                                                      |   Type    | Required | Helm Template |                        Default                        | Description                                           |
| :------------------------------------------------------- | :-------: | :------: | :-----------: | :---------------------------------------------------: | :---------------------------------------------------- |
| controllers.[controller-name].schedule                   | `string`  |    ✅    |      ✅       |                         `""`                          | Define the schedule                                   |
| controllers.[controller-name].timezone                   | `string`  |    ❌    |      ✅       |                  `{{ .Values.TZ }}`                   | Define the timezone                                   |
| controllers.[controller-name].concurrencyPolicy          | `string`  |    ❌    |      ✅       |                       `Forbid`                        | Define the concurrencyPolicy (Allow, Replace, Forbid) |
| controllers.[controller-name].failedJobsHistoryLimit     |   `int`   |    ❌    |      ❌       |                          `1`                          | Define the failedJobsHistoryLimit                     |
| controllers.[controller-name].successfulJobsHistoryLimit |   `int`   |    ❌    |      ❌       |                          `3`                          | Define the successfulJobsHistoryLimit                 |
| controllers.[controller-name].startingDeadlineSeconds    |   `int`   |    ❌    |      ❌       |                                                       | Define the startingDeadlineSeconds                    |
| controllers.[controller-name].completionMode             | `string`  |    ❌    |      ❌       |                     `NonIndexed`                      | Define the completionMode (Indexed, NonIndexed)       |
| controllers.[controller-name].backoffLimit               |   `int`   |    ❌    |      ❌       |                          `5`                          | Define the backoffLimit                               |
| controllers.[controller-name].completions                |   `int`   |    ❌    |      ❌       |                                                       | Define the completions                                |
| controllers.[controller-name].parallelism                |   `int`   |    ❌    |      ❌       |                          `1`                          | Define the parallelism                                |
| controllers.[controller-name].ttlSecondsAfterFinished    |   `int`   |    ❌    |      ❌       |                         `120`                         | Define the ttlSecondsAfterFinished                    |
| controllers.[controller-name].activeDeadlineSeconds      |   `int`   |    ❌    |      ❌       |                                                       | Define the activeDeadlineSeconds                      |

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
    type: CronJob
    labels: {}
    annotations: {}
    schedule: "{{ .Values.cron }}"
    timezone: "{{ .Values.someTZ }}"
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
      labels: {}
      annotations: {}
      hostNetwork: false
      enableServiceLinks: false
      restartPolicy: OnFailure

  other-controller-name:
    enabled: true
    primary: false
    type: CronJob
    labels: {}
    annotations: {}
    schedule: "* * * * *"
    podSpec: {}
```
