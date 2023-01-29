# Secret

| Key                               |   Type    | Required | Helm Template | Default  | Description                       |
| :-------------------------------- | :-------: | :------: | :-----------: | :------: | :-------------------------------- |
| secrets                           |  `dict`   |    ❌    |      ❌       |   `{}`   | Define the secrets as dicts       |
| secrets.[secret-name]             |  `dict`   |    ✅    |      ❌       |   `{}`   | Holds secret definition           |
| secrets.[secret-name].enabled     | `boolean` |    ✅    |      ❌       | `false`  | Enables or Disables the secret    |
| secrets.[secret-name].labels      |  `dict`   |    ❌    |      ✅       |   `{}`   | Additional labels for secret      |
| secrets.[secret-name].annotations |  `dict`   |    ❌    |      ✅       |   `{}`   | Additional annotations for secret |
| secrets.[secret-name].type        | `string`  |    ❌    |      ✅       | `Opaque` | Custom secret type                |
| secrets.[secret-name].data        |  `dict`   |    ✅    |      ✅       |   `{}`   | Define the data of the secret     |

---

Appears in:

- `.Values.secrets`

---

Naming scheme:

- `$FullName-$SecretName` (release-name-chart-name-SecretName)

---

Examples:

```yaml
secrets:

  secret-name:
    enabled: true
    labels:
      key: value
      type: CustomSecretType
      keytpl: "{{ .Values.some.value }}"
    annotations:
      key: value
      keytpl: "{{ .Values.some.value }}"
      data:
        key: value

  other-secret-name:
    enabled: true
      data:
        key: |
          multi line
          text value
```
