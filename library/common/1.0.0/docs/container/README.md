# Container

Assume every key bellow has a prefix of `workload.[workload-name].podSpec`.

| Key                                 |   Type    | Required | Helm Template | Default | Description                       |
| :---------------------------------- | :-------: | :------: | :-----------: | :-----: | :-------------------------------- |
| containers.[container-name]         |  `dict`   |    ✅    |      ❌       |  `{}`   | Define the container as dict      |
| containers.[container-name].enabled | `boolean` |    ✅    |      ❌       | `false` | Enables or Disables the container |
| containers.[container-name].primary | `boolean` |    ✅    |      ❌       | `false` | Sets the container as primary     |
| containers.[container-name].stdin   | `boolean` |    ❌    |      ❌       | `false` | whether to enable stdin or not    |
| containers.[container-name].tty     | `boolean` |    ❌    |      ❌       | `false` | whether to enable tty or not      |

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$ContainerName` (release-name-chart-name-container-name)

---

Examples:

```yaml
workload:
  workload-name:
    enabled: true
    primary: true
    labels:
      key: value
    annotations:
      key: value
    podSpec:
      containers:
        container-name:
          enabled: true
          primary: true
          stdin: true
          tty: true
```
