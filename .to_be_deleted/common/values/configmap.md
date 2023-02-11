# ConfigMap

| Key                                           |  Type   | Helm Template | Default | Description                                                            |
| :-------------------------------------------- | :-----: | :-----------: | :-----: | :--------------------------------------------------------------------- |
| configmap                                     | object  |      Yes      |  `{}`   | [configmap](#configmap)                                                |
| configmap.[configmap-name]                    | object  |      Yes      |  `{}`   | [configmap](#configmap)                                                |
| configmap.[configmap-name].enabled            | boolean |      Yes      |  unset  | Enables or Disables the configmap                                      |
| configmap.[configmap-name].labels             | object  |      Yes      |  `{}`   | Specify labels for the configmap                                       |
| configmap.[configmap-name].annotations        | object  |      Yes      |  `{}`   | Specify annotations for the configmap                                  |
| configmap.[configmap-name].nameOverride       | string  |      Yes      |  `""`   | Specify a name override for the configmap                              |
| configmap.[configmap-name].parseAsEnv         | boolean |      Yes      |  unset  | Specify if the `content` should be parsed as envs (for the Dupe Check) |
| configmap.[configmap-name].content            | object  |      Yes      |  `{}`   | Specify the content of the configmap                                   |
| configmap.[configmap-name].content.[key-name] | string  |      Yes      |  `""`   | Specify the value of the key. String and Scalar is supported           |

## configmap

Creates a configmap based on the `content`

> When parseAsEnv is checked, content will be checked against `env`, `envList`, `fixedEnvs` and
> other configmaps / secrets for duplicate envs. This can be useful to prevent overriding other envs
> either by mistake or user not knowing that the env is already set by the app developer

---

Can be defined in:

- `.Values`.configmap

---

Examples:

```yaml
configmap:
  somename:
    enabled: true
    content:
      somekey: value
      otherkey: othervalue

configmap:
  somename:
    enabled: true
    content:
      somekey: value
      nginx.conf: |
        listen {{ .Values.service.main.ports.main.port }}
```
