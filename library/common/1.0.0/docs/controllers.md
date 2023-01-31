# Controllers

| Key                                                      |   Type    | Required | Helm Template |                        Default                        | Description                                                                          |
| :------------------------------------------------------- | :-------: | :------: | :-----------: | :---------------------------------------------------: | :----------------------------------------------------------------------------------- |
| controllers                                              |  `dict`   |    ❌    |      ❌       |                         `{}`                          | Define the controllers as dicts                                                      |
| controllers.[controller-name]                            |  `dict`   |    ✅    |      ❌       |                         `{}`                          | Holds controller definition                                                          |
| controllers.[controller-name].enabled                    | `boolean` |    ✅    |      ❌       |                        `false`                        | Enables or Disables the controller                                                   |
| controllers.[controller-name].primary                    | `boolean` |    ✅    |      ❌       |                        `false`                        | Sets the controller as primary                                                       |
| controllers.[controller-name].labels                     |  `dict`   |    ❌    |      ✅       |                         `{}`                          | Additional labels for controller                                                     |
| controllers.[controller-name].annotations                |  `dict`   |    ❌    |      ✅       |                         `{}`                          | Additional annotations for controller                                                |
| controllers.[controller-name].type                       | `string`  |    ✅    |      ❌       |                         `""`                          | Define the kind of the controller (Deployment, DaemonSet, StatefulSet, CronJob, Job) |
| controllers.[controller-name].podSpec                    |  `dict`   |    ✅    |      ❌       |                         `{}`                          | Holds the pod definition                                                             |
| controllers.[controller-name].podSpec.labels             |  `dict`   |    ❌    |      ✅       |                         `{}`                          | Pod Labels                                                                           |
| controllers.[controller-name].podSpec.annotations        |  `dict`   |    ❌    |      ✅       |                         `{}`                          | Pod Annotations                                                                      |
| controllers.[controller-name].podSpec.hostNetwork        | `boolean` |    ❌    |      ❌       |    `{{ .Values.podOptions.hostNetwork }}` (false)     | Pod's hostNetwork                                                                    |
| controllers.[controller-name].podSpec.enableServiceLinks | `boolean` |    ❌    |      ❌       | `{{ .Values.podOptions.enableServiceLinks }}` (false) | Pod's enableServiceLinks                                                             |
| controllers.[controller-name].podSpec.restartPolicy      | `string`  |    ❌    |      ✅       |   `{{ .Values.podOptions.restartPolicy }}` (Always)   | Pod's restartPolicy. (Always, Never, OnFailure)                                      |
| controllers.[controller-name].podSpec.schedulerName      | `string`  |    ❌    |      ✅       |     `{{ .Values.podOptions.schedulerName }}` ("")     | Pod's schedulerName                                                                  |
| controllers.[controller-name].podSpec.priorityClassName  | `string`  |    ❌    |      ✅       |   `{{ .Values.podOptions.priorityClassName }}` ("")   | Pod's priorityClassName                                                              |
| controllers.[controller-name].podSpec.hostname           | `string`  |    ❌    |      ✅       |                         `""`                          | Pod's hostname                                                                       |

---

Appears in:

- `.Values.controllers`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$ControllerName` (release-name-chart-name-controller-name)

---

> Those are the common `keys` for all controllers.
> Additional keys, information and examples, see on the specific kind of controller

- [Deployment](deployment.md)
- [DaemonSet](daemonset.md)
- [StatefulSet](statefulset.md)
- [CronJob](cronjob.md)
- [Job](job.md)

---

Examples:

```yaml
controllers:
  controller-name:
    enabled: true
    primary: true
    labels: {}
    annotations: {}
    podSpec:
      labels: {}
      annotations: {}
      hostNetwork: false
      enableServiceLinks: false
      schedulerName: some-scheduler
      priorityClassName: some-priority-class-name
      hostname: some-hostname
```
