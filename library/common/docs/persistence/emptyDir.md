# emptyDir

| Key                              |   Type   | Required | Helm Template | Default | Description                                |
| :------------------------------- | :------: | :------: | :-----------: | :-----: | :----------------------------------------- |
| persistence.[volume-name].size   | `string` |    ❌    |      ✅       |  `""`   | Define the sizeLimit of the emptyDir       |
| persistence.[volume-name].medium | `string` |    ❌    |      ✅       |  `""`   | Define the medium of emptyDir (Memory, "") |

---

Notes:

View common `keys` of `persistence` in [persistence Documentation](README.md).

---

Examples:

```yaml
persistence:
  emptyDir-vol:
    enabled: true
    type: emptyDir
    medium: Memory
    size: 2Gi
```
