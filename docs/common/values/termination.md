# Termination

| Key                           |  Type  | Helm Template | Default | Description                                                                                 |
| :---------------------------- | :----: | :-----------: | :-----: | :------------------------------------------------------------------------------------------ |
| termination                   | object |      Yes      |  `{}`   | [termination](#termination)                                                                 |
| termination.messagePath       | string |      Yes      |  `""`   | Specify the message path for the termination                                                |
| termination.messagePolicy     | string |      Yes      |  `""`   | Specify the message policy for the termination. Allowed values: File, FallbackToLogsOnError |
| terminationGracePeriodSeconds |  int   |      Yes      |  `10`   | [terminationGracePeriodSeconds](#terminationgraceperiodseconds)                             |

---

## termination

Can be defined in:

- `.Values`.termination.messagePath
- `.Values`.termination.messagePolicy
- `.Values.additionalContainers.[container-name]`.termination.messagePath
- `.Values.additionalContainers.[container-name]`.termination.messagePolicy
- `.Values.initContainers.[container-name]`.termination.messagePath
- `.Values.initContainers.[container-name]`.termination.messagePolicy
- `.Values.installContainers.[container-name]`.termination.messagePath
- `.Values.installContainers.[container-name]`.termination.messagePolicy
- `.Values.upgradeContainers.[container-name]`.termination.messagePath
- `.Values.upgradeContainers.[container-name]`.termination.messagePolicy
- `.Values.systemContainers.[container-name]`.termination.messagePath
- `.Values.systemContainers.[container-name]`.termination.messagePolicy
- `.Values.jobs.[job-name].podSpec.containers.[container-name].[container-name]`.termination.messagePath
- `.Values.jobs.[job-name].podSpec.containers.[container-name].[container-name]`.termination.messagePolicy

---

Examples:

```yaml
termination:
  messagePath: ""
  # messagePath: "{{ .Values.some.path }}"
  messagePolicy: ""
  # messagePolicy: "{{ .Values.some.policy }}"
```

## terminationGracePeriodSeconds

Specify the termination grace period in seconds

Can be defined in:

- `.Values`.terminationGracePeriodSeconds
- `.Values.jobs.[job-name].podSpec`.terminationGracePeriodSeconds
