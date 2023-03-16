# ConfigMap

| Key                                    |   Type    | Required |   Helm Template    | Default | Description                          |
| :------------------------------------- | :-------: | :------: | :----------------: | :-----: | :----------------------------------- |
| configmap                              |  `dict`   |    ❌    |         ❌         |  `{}`   | Define the configMaps as dicts       |
| configmap.[configmap-name]             |  `dict`   |    ✅    |         ❌         |  `{}`   | Holds configMap definition           |
| configmap.[configmap-name].enabled     | `boolean` |    ✅    |         ❌         | `false` | Enables or Disables the configMap    |
| configmap.[configmap-name].labels      |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional labels for configmap      |
| configmap.[configmap-name].annotations |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional annotations for configmap |
| configmap.[configmap-name].data        |  `dict`   |    ✅    |         ✅         |  `{}`   | Define the data of the configmap     |

---

Appears in:

- `.Values.configmap`

---

Naming scheme:

- `$FullName-$ConfigmapName` (release-name-chart-name-configmapName)

---

Examples:

```yaml
configmap:

  configmap-name:
    enabled: true
    labels:
      key: value
      keytpl: "{{ .Values.some.value }}"
    annotations:
      key: value
      keytpl: "{{ .Values.some.value }}"
    data:
      key: value

  other-configmap-name:
    enabled: true
    data:
      key: |
        multi line
        text value
```
