# Secret

| Key                                     |  Type   | Helm Template | Default | Description                                                            |
| :-------------------------------------- | :-----: | :-----------: | :-----: | :--------------------------------------------------------------------- |
| secret                                  | object  |      Yes      |  `{}`   | [secret](#secret)                                                      |
| secret.[secret-name]                    | object  |      Yes      |  `{}`   | [secret](#secret)                                                      |
| secret.[secret-name].enabled            | boolean |      Yes      |  unset  | Enables or Disables the secret                                         |
| secret.[secret-name].labels             | object  |      Yes      |  `{}`   | Specify labels for the secret                                          |
| secret.[secret-name].annotations        | object  |      Yes      |  `{}`   | Specify annotations for the secret                                     |
| secret.[secret-name].nameOverride       | string  |      Yes      |  `""`   | Specify a name override for the secret                                 |
| secret.[secret-name].parseAsEnv         | boolean |      Yes      |  unset  | Specify if the `content` should be parsed as envs (for the Dupe Check) |
| secret.[secret-name].content            | object  |      Yes      |  `{}`   | Specify the content of the secret                                      |
| secret.[secret-name].content.[key-name] | string  |      Yes      |  `""`   | Specify the value of the key. String and Scalar is supported           |

## secret

Creates a secret based on the `content`

> When parseAsEnv is checked, content will be checked against `env`, `envList`, `fixedEnvs` and
> other configmaps / secrets for duplicate envs. This can be useful to prevent overriding other envs
> either by mistake or user not knowing that the env is already set by the app developer

---

Can be defined in:

- `.Values`.secret

---

Examples:

```yaml
secret:
  somename:
    enabled: true
    content:
      somekey: value
      otherkey: othervalue

secret:
  somename:
    enabled: true
    content:
      somekey: value
      nginx.conf: |
        listen {{ .Values.service.main.ports.main.port }}
```
