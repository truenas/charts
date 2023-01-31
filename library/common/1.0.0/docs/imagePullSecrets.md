# Image Pull Secrets

| Key                                                 |   Type    | Required | Helm Template | Default | Description                                     |
| :-------------------------------------------------- | :-------: | :------: | :-----------: | :-----: | :---------------------------------------------- |
| imagePullSecrets                                    |  `dict`   |    ❌    |      ❌       |  `{}`   | Define the image pull secrets as dicts          |
| imagePullSecrets.[pull-secret-name]                 |  `dict`   |    ✅    |      ❌       |  `{}`   | Holds configMap definition                      |
| imagePullSecrets.[pull-secret-name].enabled         | `boolean` |    ✅    |      ❌       | `false` | Enables or Disables the image pull secret       |
| imagePullSecrets.[pull-secret-name].labels          |  `dict`   |    ❌    |      ✅       |  `{}`   | Additional labels for image pull secret         |
| imagePullSecrets.[pull-secret-name].annotations     |  `dict`   |    ❌    |      ✅       |  `{}`   | Additional annotations for image pull secret    |
| imagePullSecrets.[pull-secret-name].data            |  `dict`   |    ✅    |      ✅       |  `{}`   | Define the data of the image pull secret        |
| imagePullSecrets.[pull-secret-name].data.registry   | `string`  |    ✅    |      ✅       |  `""`   | Define the registry of the image pull secret    |
| imagePullSecrets.[pull-secret-name].data.username   | `string`  |    ✅    |      ✅       |  `""`   | Define the username of the image pull secret    |
| imagePullSecrets.[pull-secret-name].data.password   | `string`  |    ✅    |      ✅       |  `""`   | Define the password of the image pull secret    |
| imagePullSecrets.[pull-secret-name].data.email      | `string`  |    ✅    |      ✅       |  `""`   | Define the email of the image pull secret       |
| imagePullSecrets.[pull-secret-name].targetSelectAll | `boolean` |    ❌    |      ❌       |         | Whether to assign the secret to all pods or not |
| imagePullSecrets.[pull-secret-name].targetSelector  |  `list`   |    ❌    |      ❌       |  `""`   | Define the pod(s) to assign the secret          |

> When `targetSelectAll` is `true`, it will assign the secret to all pods (`targetSelector` is ignored in this case)
> When `targetSelector` is a list, it's entry is a string, referencing the pod(s) name that will be assigned.
> When `targetSelector` is a empty, it will assign the secret to the primary pod

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
      targetSelectAll: true

  other-pull-secret-name:
    enabled: true
      data:
        registry: "{{ .Values.my_registry }}"
        username: "{{ .Values.my_user }}"
        password: "{{ .Values.my_pass }}"
        email: "{{ .Values.my_mail }}"
      targetSelector:
        - controller-name1
        - controller-name2
```
