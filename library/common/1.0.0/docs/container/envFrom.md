# Env From

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key                                   |   Type    | Required | Helm Template | Default | Description                                                          |
| :------------------------------------ | :-------: | :------: | :-----------: | :-----: | :------------------------------------------------------------------- |
| envFrom                               |  `list`   |    ❌    |      ❌       |  `{}`   | Define envFrom for the container                                     |
| envFrom.secretRef                     |  `dict`   |    ✅    |      ❌       |  `{}`   | Define the secretRef                                                 |
| envFrom.secretRef.name                | `string`  |    ✅    |      ✅       |  `""`   | Define the secret name                                               |
| envFrom.secretRef.expandObjectName    | `boolean` |    ❌    |      ❌       | `true`  | Whether to expand (adding the fullname as prefix) the secret name    |
| envFrom.configMapRef                  |  `dict`   |    ✅    |      ❌       |  `{}`   | Define the configMapRef                                              |
| envFrom.configMapRef.name             | `string`  |    ✅    |      ✅       |  `""`   | Define the configmap name                                            |
| envFrom.configMapRef.expandObjectName | `boolean` |    ❌    |      ❌       | `true`  | Whether to expand (adding the fullname as prefix) the configmap name |

> When the `expandObjectName` is `true`, it will also scan the contents of the secret/configmap
> for duplicate keys between other secrets/configmaps/env/envList/fixedEnv and will throw an error if it finds any.
> `expandObjectName` should only be set to `false` if you want to consume a secret/configmap created outside of this chart

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].envFrom`

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
          envFrom:
            - secretRef:
                # This will be expanded to `fullname-secret-name`
                name: secret-name
            - configMapRef:
                name: configmap-name
                expandObjectName: false
```
