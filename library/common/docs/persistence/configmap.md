# configmap

| Key                                        |   Type    | Required | Helm Template | Default | Description                                                          |
| :----------------------------------------- | :-------: | :------: | :-----------: | :-----: | :------------------------------------------------------------------- |
| persistence.[volume-name].objectName       | `string`  |    ✅    |      ✅       |  `""`   | Define the configmap volume name                                     |
| persistence.[volume-name].expandObjectName | `boolean` |    ❌    |      ❌       | `true`  | Whether to expand (adding the fullname as prefix) the configmap name |
| persistence.[volume-name].defaultMode      | `string`  |    ❌    |      ✅       |  `""`   | Define the defaultMode (must be a string in format of "0777")        |
| persistence.[volume-name].items            |  `list`   |    ❌    |      ❌       |  `[]`   | Define a list of items for configmap                                 |
| persistence.[volume-name].items.key        | `string`  |    ✅    |      ✅       |  `""`   | Define the key of the configmap                                      |
| persistence.[volume-name].items.path       | `string`  |    ✅    |      ✅       |  `""`   | Define the path                                                      |

---

Notes:

View common `keys` of `persistence` in [persistence Documentation](README.md).

---

Examples:

```yaml
persistence:
  configmap-vol:
    enabled: true
    type: configmap
    objectName: configmap-name
    expandObjectName: false
    defaultMode: "0777"
    items:
      - key: key1
        path: path1
      - key: key2
        path: path2
```
