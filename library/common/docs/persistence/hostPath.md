# hostPath

| Key                                    |   Type   | Required | Helm Template | Default | Description             |
| :------------------------------------- | :------: | :------: | :-----------: | :-----: | :---------------------- |
| persistence.[volume-name].hostPath     | `string` |    ✅    |      ✅       |  `""`   | Define the hostPath     |
| persistence.[volume-name].hostPathType | `string` |    ❌    |      ✅       |  `""`   | Define the hostPathType |

---

Notes:

View common `keys` of `persistence` in [persistence Documentation](README.md).

---

Examples:

```yaml
persistence:
  hostpath-vol:
    enabled: true
    type: hostPath
    hostPath: /path/to/host
    hostPathType: DirectoryOrCreate
```
