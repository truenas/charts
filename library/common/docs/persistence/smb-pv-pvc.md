# smb-pv-pvc

| Key                                            |     Type      | Required |   Helm Template    |                        Default                         | Description                                                                                                                      |
| :--------------------------------------------- | :-----------: | :------: | :----------------: | :----------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------- |
| persistence.[volume-name].labels               |    `dict`     |    ❌    | ✅ (On value only) |                          `{}`                          | Additional labels for persistence                                                                                                |
| persistence.[volume-name].annotations          |    `dict`     |    ❌    | ✅ (On value only) |                          `{}`                          | Additional annotations for persistence                                                                                           |
| persistence.[volume-name].retain               |   `boolean`   |    ❌    |         ❌         |   `{{ .Values.global.fallbackDefaults.pvcRetain }}`    | Define wether the to add helm annotation to retain resource on uninstall (Middleware should also retain it when deleting the NS) |
| persistence.[volume-name].accessModes          | `string/list` |    ❌    |         ✅         | `{{ .Values.global.fallbackDefaults.pvcAccessModes }}` | Define the accessModes of the PVC, if it's single can be defined as a string, multiple as a list                                 |
| persistence.[volume-name].size                 |   `string`    |    ❌    |         ✅         |    `{{ .Values.global.fallbackDefaults.pvcSize }}`     | Define the size of the PVC                                                                                                       |
| persistence.[volume-name].server               |   `string`    |    ✅    |         ✅         |                          `""`                          | Define SMB Server                                                                                                                |
| persistence.[volume-name].share                |   `string`    |    ✅    |         ✅         |                          `""`                          | Define SMB Share                                                                                                                 |
| persistence.[volume-name].username             |   `string`    |    ✅    |         ✅         |                          `""`                          | Define SMB Username                                                                                                              |
| persistence.[volume-name].password             |   `string`    |    ✅    |         ✅         |                          `""`                          | Define SMB Password                                                                                                              |
| persistence.[volume-name].mountOptions         |    `list`     |    ❌    |         ✅         |                          `[]`                          | Define mount options for the CSI                                                                                                 |
| persistence.[volume-name].mountOptions[].key   |   `string`    |    ✅    |         ✅         |                          `[]`                          | Define key of mount option for the CSI                                                                                           |
| persistence.[volume-name].mountOptions[].value |   `string`    |    ❌    |         ✅         |                          `[]`                          | Define value of mount option for the CSI                                                                                         |

---

Notes:

View common `keys` of `persistence` in [Persistence Documentation](README.md).

---

Examples:

```yaml
persistence:
  pvc-vol:
    enabled: true
    type: smb-pv-pvc
    labels:
      label1: value1
    annotations:
      annotation1: value1
    accessModes:
      - ReadWriteOnce
    retain: false
    size: 2Gi
    server: my-server.mydomain.local
    share: my-share
    username: my-username
    password: my-password
    mountOptions:
      - key: vers
        value: "3.0"
      - key: dir_mode
        value: "0777"
      - key: noperm
    # targetSelectAll: true
    targetSelector:
      pod-name:
        container-name:
          mountPath: /path/to/mount
```
