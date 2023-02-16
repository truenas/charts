# Env

Assume every key below has a prefix of `workload.[workload-name].podSpec.containers.[container-name]`.

| Key                                        |   Type    | Required |  Helm Template  | Default | Description                                                          |
| :----------------------------------------- | :-------: | :------: | :-------------: | :-----: | :------------------------------------------------------------------- |
| env                                        |  `dict`   |    ❌    |       ❌        |  `{}`   | Define env(s) for the container                                      |
| env.[key]                                  | `string`  |    ✅    | ✅ (Only value) |  `""`   | Define the env key/value                                             |
| env.[key].configMapKeyRef                  |  `dict`   |    ❌    |       ❌        |  `{}`   | Define variable from configMapKeyRef                                 |
| env.[key].configMapKeyRef.name             | `string`  |    ✅    |       ✅        |  `""`   | Define the configMap name                                            |
| env.[key].configMapKeyRef.key              | `string`  |    ✅    |       ❌        |  `""`   | Define the configMap key                                             |
| env.[key].configMapKeyRef.expandObjectName | `boolean` |    ❌    |       ❌        | `true`  | Whether to expand (adding the fullname as prefix) the configmap name |
| env.[key].secretKeyRef                     |  `dict`   |    ❌    |       ❌        |  `{}`   | Define secretKeyRef variable                                         |
| env.[key].secretKeyRef.name                | `string`  |    ✅    |       ✅        |  `""`   | Define the secret name                                               |
| env.[key].secretKeyRef.key                 | `string`  |    ✅    |       ❌        |  `""`   | Define the secret key                                                |
| env.[key].secretKeyRef.expandObjectName    | `boolean` |    ❌    |       ❌        | `true`  | Whether to expand (adding the fullname as prefix) the secret name    |
| env.[key].fieldRef                         |  `dict`   |    ❌    |       ❌        |  `{}`   | Define fieldRef variable                                             |
| env.[key].fieldRef.fieldPath               | `string`  |    ✅    |       ❌        |  `""`   | Define field path                                                    |
| env.[key].fieldRef.apiVersion              | `string`  |    ❌    |       ❌        |  `""`   | Define apiVersion                                                    |

> Environment variables defined in `env` will be scanned for duplicate keys
> between other secrets/configmaps/env/envList/fixedEnv and will throw an error if it finds any.
> `secretKeyRef` and `configMapKeyRef` with `expandObjectName` set to `true` will also be validated that
> the actual objects are defined and have the specified key.
> `expandObjectName` should only be set to `false` if you want to consume a secret/configmap created outside of this chart

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name].env`

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
          env:
            ENV_NAME1: ENV_VALUE
            ENV_NAME2: "{{ .Values.some.path }}"
            ENV_NAME3:
              configMapKeyRef:
                # This will be expanded to 'fullname-configmap-name'
                name: configmap-name
                key: configmap-key
            ENV_NAME4:
              secretKeyRef:
                name: secret-name
                key: secret-key
                expandObjectName: false
            ENV_NAME5:
              fieldRef:
                fieldPath: metadata.name
                apiVersion: v1
```
