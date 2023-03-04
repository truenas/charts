# Device

| Key                                    |   Type   | Required | Helm Template | Default | Description             |
| :------------------------------------- | :------: | :------: | :-----------: | :-----: | :---------------------- |
| persistence.[volume-name].hostPath     | `string` |    ✅    |      ✅       |  `""`   | Define the hostPath     |
| persistence.[volume-name].hostPathType | `string` |    ❌    |      ✅       |  `""`   | Define the hostPathType |

> `device` type is pretty much the same as `hostPath`. The only difference is that if a `device` type is defined.
> We can take additional actions, like setting supplementalGroups to the container assigned, so it can utilize the device.

---

Notes:

View common `keys` of `persistence` in [persistence Documentation](README.md).

---

Examples:

```yaml
persistence:
  dev-vol:
    enabled: true
    type: device
    hostPath: /path/to/host
    hostPathType: BlockDevice
```
