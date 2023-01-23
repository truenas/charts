# Termination

## Key: termination

Info:

- Type: `dict`
- Default:

  ```yaml
  termination:
    messagePath: ""
    messagePolicy: ""
    gracePeriodSeconds: 10
  ```

- Helm Template:
  - messagePath: ✅
  - messagePolicy: ✅
  - gracePeriodSeconds: ❌

Can be defined in:

- `.Values`.termination.messagePath
- `.Values`.termination.messagePolicy
- `.Values`.termination.gracePeriodSeconds
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
- `.Values.jobs.[job-name].podSpec`.termination.gracePeriodSeconds
- `.Values.jobs.[job-name].podSpec.containers.[container-name].[container-name]`.termination.messagePath
- `.Values.jobs.[job-name].podSpec.containers.[container-name].[container-name]`.termination.messagePolicy

---

`messagePath` and `messagePolicy` can be set per container.
`gracePeriodSeconds` can only be set per pod.

Examples:

```yaml
termination:
  messagePath: ""
  # messagePath: "{{ .Values.some.path }}"
  messagePolicy: ""
  # messagePolicy: "{{ .Values.some.path }}"
  gracePeriodSeconds: 10
```
