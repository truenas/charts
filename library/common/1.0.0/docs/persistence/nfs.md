# nfs

| Key                              |   Type   | Required | Helm Template | Default | Description                      |
| :------------------------------- | :------: | :------: | :-----------: | :-----: | :------------------------------- |
| persistence.[volume-name].path   | `string` |    ✅    |      ✅       |  `""`   | Define the nfs export share path |
| persistence.[volume-name].server | `string` |    ✅    |      ✅       |  `""`   | Define the nfs server            |

---

Notes:

View common `keys` of `persistence` in [persistence Documentation](README.md).

---

Examples:

```yaml
persistence:
  nfs-vol:
    enabled: true
    type: nfs
    path: /path/of/nfs/share
    server: nfs-server
```
