# Image Pull Secret

| Key                                                |   Type    | Required |   Helm Template    | Default | Description                                     |
| :------------------------------------------------- | :-------: | :------: | :----------------: | :-----: | :---------------------------------------------- |
| imagePullSecret                                    |  `dict`   |    ❌    |         ❌         |  `{}`   | Define the image pull secret as dicts           |
| imagePullSecret.[pull-secret-name]                 |  `dict`   |    ✅    |         ❌         |  `{}`   | Holds configMap definition                      |
| imagePullSecret.[pull-secret-name].enabled         | `boolean` |    ✅    |         ❌         | `false` | Enables or Disables the image pull secret       |
| imagePullSecret.[pull-secret-name].labels          |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional labels for image pull secret         |
| imagePullSecret.[pull-secret-name].annotations     |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional annotations for image pull secret    |
| imagePullSecret.[pull-secret-name].data            |  `dict`   |    ✅    |         ✅         |  `{}`   | Define the data of the image pull secret        |
| imagePullSecret.[pull-secret-name].data.registry   | `string`  |    ✅    |         ✅         |  `""`   | Define the registry of the image pull secret    |
| imagePullSecret.[pull-secret-name].data.username   | `string`  |    ✅    |         ✅         |  `""`   | Define the username of the image pull secret    |
| imagePullSecret.[pull-secret-name].data.password   | `string`  |    ✅    |         ✅         |  `""`   | Define the password of the image pull secret    |
| imagePullSecret.[pull-secret-name].data.email      | `string`  |    ✅    |         ✅         |  `""`   | Define the email of the image pull secret       |
| imagePullSecret.[pull-secret-name].targetSelectAll | `boolean` |    ❌    |         ❌         |         | Whether to assign the secret to all pods or not |
| imagePullSecret.[pull-secret-name].targetSelector  |  `list`   |    ❌    |         ❌         |  `[]`   | Define the pod(s) to assign the secret          |

> When `targetSelectAll` is `true`, it will assign the secret to all pods (`targetSelector` is ignored in this case)
> When `targetSelector` is a list, each entry is a string with the pod name that will be assigned. Can have multiple entries
> When `targetSelector` is a empty, it will assign the secret to the primary pod

---

Appears in:

- `.Values.imagePullSecret`

---

Naming scheme:

- `$FullName-$ImagePullSecretName` (release-name-chart-name-imagePullSecretName)

---

Examples:

```yaml
imagePullSecret:

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
        - workload-name1
        - workload-name2
```
