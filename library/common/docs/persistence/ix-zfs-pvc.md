# ix-zfs-pvc

| Key                                   |     Type      | Required |   Helm Template    |                        Default                         | Description                                                                                                                      |
| :------------------------------------ | :-----------: | :------: | :----------------: | :----------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------- |
| persistence.[volume-name].labels      |    `dict`     |    ❌    | ✅ (On value only) |                          `{}`                          | Additional labels for persistence                                                                                                |
| persistence.[volume-name].annotations |    `dict`     |    ❌    | ✅ (On value only) |                          `{}`                          | Additional annotations for persistence                                                                                           |
| persistence.[volume-name].retain      |   `boolean`   |    ❌    |         ❌         |   `{{ .Values.global.fallbackDefaults.pvcRetain }}`    | Define wether the to add helm annotation to retain resource on uninstall (Middleware should also retain it when deleting the NS) |
| persistence.[volume-name].accessModes | `string/list` |    ❌    |         ✅         | `{{ .Values.global.fallbackDefaults.pvcAccessModes }}` | Define the accessModes of the PVC, if it's single can be defined as a string, multiple as a list                                 |
| persistence.[volume-name].size        |   `string`    |    ❌    |         ✅         |    `{{ .Values.global.fallbackDefaults.pvcSize }}`     | Define the size of the PVC                                                                                                       |

> This type can only be used within TrueNAS SCALE
> It will use the storage class name injected by the middleware

---

Notes:

View common `keys` of `persistence` in [Persistence Documentation](README.md).

---

Examples:

```yaml
persistence:
  pvc-vol:
    enabled: true
    type: ix-zfs-pvc
    labels:
      label1: value1
    annotations:
      annotation1: value1
    accessModes: ReadWriteOnce
    retain: false
    size: 2Gi
    # targetSelectAll: true
    targetSelector:
      pod-name:
        container-name:
          mountPath: /path/to/mount
```
