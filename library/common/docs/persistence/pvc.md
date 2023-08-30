# pvc

| Key                                        |     Type      | Required |   Helm Template    |                        Default                         | Description                                                                                                                      |
| :----------------------------------------- | :-----------: | :------: | :----------------: | :----------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------- |
| persistence.[volume-name].labels           |    `dict`     |    ❌    | ✅ (On value only) |                          `{}`                          | Additional labels for persistence                                                                                                |
| persistence.[volume-name].annotations      |    `dict`     |    ❌    | ✅ (On value only) |                          `{}`                          | Additional annotations for persistence                                                                                           |
| persistence.[volume-name].retain           |   `boolean`   |    ❌    |         ❌         |   `{{ .Values.global.fallbackDefaults.pvcRetain }}`    | Define wether the to add helm annotation to retain resource on uninstall (Middleware should also retain it when deleting the NS) |
| persistence.[volume-name].accessModes      | `string/list` |    ❌    |         ✅         | `{{ .Values.global.fallbackDefaults.pvcAccessModes }}` | Define the accessModes of the PVC, if it's single can be defined as a string, multiple as a list                                 |
| persistence.[volume-name].volumeName       |   `string`    |    ❌    |         ✅         |                                                        | Define the volumeName of a PV, backing the claim                                                                                 |
| persistence.[volume-name].existingClaim    |   `string`    |    ❌    |         ✅         |                                                        | Define an existing claim to use                                                                                                  |
| persistence.[volume-name].storageClassName |   `string`    |    ❌    |         ✅         |                       See below                        | Define an existing claim to use                                                                                                  |
| persistence.[volume-name].size             |   `string`    |    ❌    |         ✅         |    `{{ .Values.global.fallbackDefaults.pvcSize }}`     | Define the size of the PVC                                                                                                       |

> - If storageClass is defined on the `persistence`:
>   - "-"
>     - Returns `""`, which means requesting a PV without class
>   - Else
>     - Return the original defined `storageClass`
> - Else if there is a storageClass defined in `{{ .Values.fallbackDefaults.storageClass }}`, return this

---

Notes:

View common `keys` of `persistence` in [Persistence Documentation](README.md).

---

Examples:

```yaml
persistence:
  pvc-vol:
    enabled: true
    type: pvc
    labels:
      label1: value1
    annotations:
      annotation1: value1
    accessModes: ReadWriteOnce
    volumeName: volume-name-backing-the-pvc
    existingClaim: existing-claim-name
    retain: true
    size: 2Gi
    # targetSelectAll: true
    targetSelector:
      pod-name:
        container-name:
          mountPath: /path/to/mount
```
