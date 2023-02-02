# Service Account

| Key                                      |   Type    | Required | Helm Template | Default | Description                                             |
| :--------------------------------------- | :-------: | :------: | :-----------: | :-----: | :------------------------------------------------------ |
| serviceAccount                           |  `dict`   |    ❌    |      ❌       |  `{}`   | Define the serviceAccount as dicts                      |
| serviceAccount.[sa-name]                 |  `dict`   |    ✅    |      ❌       |  `{}`   | Holds secret definition                                 |
| serviceAccount.[sa-name].enabled         | `boolean` |    ✅    |      ❌       | `false` | Enables or Disables the secret                          |
| serviceAccount.[sa-name].primary         | `boolean` |    ❌    |      ❌       | `false` | Sets the service account as primary                     |
| serviceAccount.[sa-name].labels          |  `dict`   |    ❌    |      ✅       |  `{}`   | Additional labels for secret                            |
| serviceAccount.[sa-name].annotations     |  `dict`   |    ❌    |      ✅       |  `{}`   | Additional annotations for secret                       |
| serviceAccount.[sa-name].targetSelectAll | `boolean` |    ❌    |      ❌       |         | Whether to assign the serviceAccount to all pods or not |
| serviceAccount.[sa-name].targetSelector  |  `list`   |    ❌    |      ❌       |  `[]`   | Define the pod(s) to assign the serviceAccount          |

> When `targetSelectAll` is `true`, it will assign the serviceAccount to all pods (`targetSelector` is ignored in this case)
> When `targetSelector` is a list, each entry is a string, referencing the pod(s) name that will be assigned.
> When `targetSelector` is a empty, it will assign the serviceAccount to the primary pod

---

Appears in:

- `.Values.serviceAccount`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$ServiceAccountName` (release-name-chart-name-ServiceAccountName)

---

Examples:

```yaml
serviceAccount:
  sa-name:
    enabled: true
    labels:
      key: value
      keytpl: "{{ .Values.some.value }}"
    annotations:
      key: value
      keytpl: "{{ .Values.some.value }}"
    targetSelectAll: true

  other-sa-name:
    enabled: true
    targetSelector:
      - pod-name
      - other-pod-name
```
