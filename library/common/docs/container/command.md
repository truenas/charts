# Command

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key     |     Type      | Required | Helm Template | Default | Description                                                 |
| :------ | :-----------: | :------: | :-----------: | :-----: | :---------------------------------------------------------- |
| command | `list/string` |    ❌    |      ✅       |  `[]`   | Define command(s). If it's single, can be defined as string |

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].command`

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
          # As a list
          command:
            - command1
            - command2
          # As a string
          command: command
```
