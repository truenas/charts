# Service Account

| Key                                      |   Type    | Required |   Helm Template    | Default | Description                                             |
| :--------------------------------------- | :-------: | :------: | :----------------: | :-----: | :------------------------------------------------------ |
| serviceAccount                           |  `dict`   |    ❌    |         ❌         |  `{}`   | Define the serviceAccount as dicts                      |
| serviceAccount.[sa-name]                 |  `dict`   |    ✅    |         ❌         |  `{}`   | Holds service account definition                        |
| serviceAccount.[sa-name].enabled         | `boolean` |    ✅    |         ❌         | `false` | Enables or Disables the service account                 |
| serviceAccount.[sa-name].primary         | `boolean` |    ❌    |         ❌         | `false` | Sets the service account as primary                     |
| serviceAccount.[sa-name].labels          |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional labels for service account                   |
| serviceAccount.[sa-name].annotations     |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional annotations for service account              |
| serviceAccount.[sa-name].targetSelectAll | `boolean` |    ❌    |         ❌         |         | Whether to assign the serviceAccount to all pods or not |
| serviceAccount.[sa-name].targetSelector  |  `list`   |    ❌    |         ❌         |  `[]`   | Define the pod(s) to assign the serviceAccount          |

> When `targetSelectAll` is `true`, it will assign the serviceAccount to all pods (`targetSelector` is ignored in this case)
> When `targetSelector` is a list, each entry is a string, with the pod name that will be assigned. Can have multiple entries.
> When `targetSelector` is a empty, it will assign the serviceAccount to the primary pod

---

Appears in:

- `.Values.serviceAccount`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$ServiceAccountName` (release-name-chart-name-ServiceAccountName)

---

Notes:

By default the `automountServiceAccountToken` is set to `false` for all service accounts.
You have to explicitly set it to `true` on per pod(workload) basis with `workload.[workload-name].podSpec.automountServiceAccountToken`

---

Examples:

```yaml
serviceAccount:
  sa-name:
    enabled: true
    primary: true
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
