# ixVolume

| Key                                    |   Type   | Required | Helm Template | Default | Description             |
| :------------------------------------- | :------: | :------: | :-----------: | :-----: | :---------------------- |
| persistence.[volume-name].datasetName  | `string` |    ✅    |      ✅       |  `""`   | Define the datasetName  |
| persistence.[volume-name].hostPathType | `string` |    ❌    |      ✅       |  `""`   | Define the hostPathType |

---

Notes:

View common `keys` of `persistence` in [persistence Documentation](README.md).

---

Examples:

```yaml
persistence:
  ix-vol:
    enabled: true
    type: ixVolume
    datasetName: ix-app
    hostPathType: DirectoryOrCreate
```
