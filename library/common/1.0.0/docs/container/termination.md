# Termination

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key                       |   Type   | Required | Helm Template | Default | Description                                         |
| :------------------------ | :------: | :------: | :-----------: | :-----: | :-------------------------------------------------- |
| termination               |  `dict`  |    ❌    |      ❌       |  `{}`   | Define termination for the container                |
| termination.messagePath   | `string` |    ❌    |      ✅       |  `""`   | Define termination message path for the container   |
| termination.messagePolicy | `string` |    ❌    |      ✅       |  `""`   | Define termination message policy for the container |

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].termination`

---

Examples:

```yaml
workload:
  workload-name:
    enabled: true
    primary: true
    podSpec:
      containers:
        container-name:
          enabled: true
          primary: true
          termination:
            messagePath: /dev/termination-log
            messagePolicy: File
```
