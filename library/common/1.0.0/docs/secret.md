# Secret

| Key                              |   Type    | Required |   Helm Template    | Default  | Description                       |
| :------------------------------- | :-------: | :------: | :----------------: | :------: | :-------------------------------- |
| secret                           |  `dict`   |    ❌    |         ❌         |   `{}`   | Define the secret as dicts        |
| secret.[secret-name]             |  `dict`   |    ✅    |         ❌         |   `{}`   | Holds secret definition           |
| secret.[secret-name].enabled     | `boolean` |    ✅    |         ❌         | `false`  | Enables or Disables the secret    |
| secret.[secret-name].labels      |  `dict`   |    ❌    | ✅ (On value only) |   `{}`   | Additional labels for secret      |
| secret.[secret-name].annotations |  `dict`   |    ❌    | ✅ (On value only) |   `{}`   | Additional annotations for secret |
| secret.[secret-name].type        | `string`  |    ❌    |         ✅         | `Opaque` | Custom secret type                |
| secret.[secret-name].data        |  `dict`   |    ✅    |         ✅         |   `{}`   | Define the data of the secret     |

---

Appears in:

- `.Values.secret`

---

Naming scheme:

- `$FullName-$SecretName` (release-name-chart-name-SecretName)

---

Examples:

```yaml
secret:

  secret-name:
    enabled: true
    type: CustomSecretType
    labels:
      key: value
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
