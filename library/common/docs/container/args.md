# Args

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key       |     Type      | Required | Helm Template | Default | Description                                                                                    |
| :-------- | :-----------: | :------: | :-----------: | :-----: | :--------------------------------------------------------------------------------------------- |
| args      | `list/string` |    ❌    |      ✅       |  `[]`   | Define arg(s). If it's single, can be defined as string                                        |
| extraArgs | `list/string` |    ❌    |      ✅       |  `[]`   | Define extraArg(s). Those are appended after the `args`. Useful for user defined args from GUI |

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].args`

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
          args: arg
          extraArgs:
            - extraArg
```
