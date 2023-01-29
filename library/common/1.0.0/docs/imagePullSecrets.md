# Image Pull Secrets

| Key                                               |   Type    | Required | Helm Template | Default | Description                                  |
| :------------------------------------------------ | :-------: | :------: | :-----------: | :-----: | :------------------------------------------- |
| imagePullSecrets                                  |  `dict`   |    ❌    |      ❌       |  `{}`   | Define the image pull secrets as dicts       |
| imagePullSecrets.[pull-secret-name]               |  `dict`   |    ✅    |      ❌       |  `{}`   | Holds configMap definition                   |
| imagePullSecrets.[pull-secret-name].enabled       | `boolean` |    ✅    |      ❌       | `false` | Enables or Disables the image pull secret    |
| imagePullSecrets.[pull-secret-name].labels        |  `dict`   |    ❌    |      ✅       |  `{}`   | Additional labels for image pull secret      |
| imagePullSecrets.[pull-secret-name].annotations   |  `dict`   |    ❌    |      ✅       |  `{}`   | Additional annotations for image pull secret |
| imagePullSecrets.[pull-secret-name].data          |  `dict`   |    ✅    |      ✅       |  `{}`   | Define the data of the image pull secret     |
| imagePullSecrets.[pull-secret-name].data.registry | `string`  |    ✅    |      ✅       |  `""`   | Define the registry of the image pull secret |
| imagePullSecrets.[pull-secret-name].data.username | `string`  |    ✅    |      ✅       |  `""`   | Define the username of the image pull secret |
| imagePullSecrets.[pull-secret-name].data.password | `string`  |    ✅    |      ✅       |  `""`   | Define the password of the image pull secret |
| imagePullSecrets.[pull-secret-name].data.email    | `string`  |    ✅    |      ✅       |  `""`   | Define the email of the image pull secret    |

---

Appears in:

- `.Values.imagePullSecrets`

---

Naming scheme:

- `$FullName-$ImagePullSecretName` (release-name-chart-name-imagePullSecretName)

---

Examples:

```yaml
imagePullSecrets:

  pull-secret-name:
    enabled: true
    labels:
      key: value
      keytpl: "{{ .Values.some.value }}"
    annotations:
      key: value
      keytpl: "{{ .Values.some.value }}"
      data:
        registry: quay.io
        username: my_user
        password: my_pass
        email: my_mail@example.com

  other-pull-secret-name:
    enabled: true
      data:
        registry: "{{ .Values.my_registry }}"
        username: "{{ .Values.my_user }}"
        password: "{{ .Values.my_pass }}"
        email: "{{ .Values.my_mail }}"
# TODO: targetSelector
```
