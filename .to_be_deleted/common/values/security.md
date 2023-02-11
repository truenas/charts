# Security

## Key: securityContext

- Type: `dict`
- Default:

  ```yaml
  securityContext:
    runAsNonRoot: true
    runAsUser: 568
    runAsGroup: 568
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    privileged: false
    capabilities:
      add: []
      drop:
        - ALL
  ```

- Helm Template: ❌

Can be defined in:

- `.Values`.securityContext
- `.Values.additionalContainers.[container-name]`.securityContext
- `.Values.systemContainers.[container-name]`.securityContext
- `.Values.initContainers.[container-name]`.securityContext
- `.Values.installContainers.[container-name]`.securityContext
- `.Values.upgradeContainers.[container-name]`.securityContext
- `.Values.jobs.[job-name].podSpec.containers.[container-name]`.securityContext

---

By default it runs as the least privileged user. A chart developer have to \
explicitly change the user and/or privileges, capabilities, etc.

Examples:

```yaml
# This will only alter the defined keys, rest keys will come from the default.
securityContext:
  runAsNonRoot: false
  runAsUser: 0
  runAsGroup: 0
  readOnlyRootFilesystem: false
```

## Key: podSecurityContext

- Type: `dict`
- Default:

  ```yaml
  podSecurityContext:
    fsGroup: 568
    supplementalGroups: []
    fsGroupChangePolicy: OnRootMismatch
  ```

- Helm Template: ❌

Can be defined in:

- `.Values`.podSecurityContext
- `.Values.jobs.[job-name].podSpec`.podSecurityContext

---

This applies on the whole pod (k8s does not offer a way to apply those per container.)

Examples:

```yaml
# This will only alter the defined keys, rest keys will come from the default.
podSecurityContext:
  fsGroup: 33
```
