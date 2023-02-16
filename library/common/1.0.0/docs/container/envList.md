# Env List

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key           |   Type   | Required | Helm Template | Default | Description                      |
| :------------ | :------: | :------: | :-----------: | :-----: | :------------------------------- |
| envList       |  `list`  |    ❌    |      ❌       |  `[]`   | Define env(s) for the container |
| envList.name  | `string` |    ✅    |      ❌       |  `""`   | Define the env name              |
| envList.value | `string` |    ❌    |      ✅       |  `""`   | Define the env value             |

> `envList` is used for the SCALE GUI for "Additional Environment Variables"
> Environment variables defined in `envList` will be scanned for duplicate keys
> between other secrets/configmaps/env/envList/fixedEnv and will throw an error if it finds any.

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].envList`

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
          envList:
            - name: ENV_NAME1
              value: ENV_VALUE
            - name: ENV_NAME2
              value: "{{ .Values.some.path }}"
            - name: ENV_NAME3
              value: ""
```
