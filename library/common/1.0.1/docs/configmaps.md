# ConfigMap

| Key                                    |   Type    | Required | Helm Template | Default | Description                          |
| :------------------------------------- | :-------: | :------: | :-----------: | :-----: | :----------------------------------- |
| configmaps                              |  `dict`   |    ❌    |      ❌       |  `{}`   | Define the configMaps as dicts       |
| configmaps.[configmap-name]             |  `dict`   |    ✅    |      ❌       |  `{}`   | Holds configMap definition           |
| configmaps.[configmap-name].enabled     | `boolean` |    ✅    |      ❌       | `false` | Enables or Disables the configMap    |
| configmaps.[configmap-name].labels      |  `dict`   |    ❌    |      ✅       |  `{}`   | Additional labels for configmap      |
| configmaps.[configmap-name].annotations |  `dict`   |    ❌    |      ✅       |  `{}`   | Additional annotations for configmap |
| configmaps.[configmap-name].data        |  `dict`   |    ✅    |      ✅       |  `{}`   | Define the data of the configmap     |

---

Appears in:

- `.Values.configmaps`

---

Naming scheme:

- `$FullName-$ConfigmapName`

---

Examples:

```yaml
configmaps:

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
          text value


```
