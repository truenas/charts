# Persistence

| Key                                                                            |     Type      |    Required     |   Helm Template    |                               Default                               | Description                                                                                                                      |
| :----------------------------------------------------------------------------- | :-----------: | :-------------: | :----------------: | :-----------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------- |
| persistence                                                                    |    `dict`     |       ❌        |         ❌         |                                `{}`                                 | Define the persistence as dicts                                                                                                  |
| persistence.[volume-name]                                                      |    `dict`     |       ✅        |         ❌         |                                `{}`                                 | Holds persistence definition                                                                                                     |
| persistence.[volume-name].enabled                                              |   `boolean`   |       ✅        |         ❌         |                               `false`                               | Enables or Disables the persistence                                                                                              |
| persistence.[volume-name].labels                                               |    `dict`     |       ❌        | ✅ (On value only) |                                `{}`                                 | Additional labels for persistence                                                                                                |
| persistence.[volume-name].annotations                                          |    `dict`     |       ❌        | ✅ (On value only) |                                `{}`                                 | Additional annotations for persistence                                                                                           |
| persistence.[volume-name].type                                                 |   `string`    |       ❌        |         ❌         |                                `pvc`                                | Define the persistence type (pvc, ixVolume, nfs, hostPath, configmap, secret)                                                    |
| persistence.[volume-name].retain                                               |   `boolean`   |       ❌        |         ❌         |          `{{ .Values.global.fallbackDefaults.pvcRetain }}`          | Define wether the to add helm annotation to retain resource on uninstall (Middleware should also retain it when deleting the NS) |
| persistence.[volume-name].accessModes                                          | `string/list` |       ❌        |         ✅         |       `{{ .Values.global.fallbackDefaults.pvcAccessModes }}`        | Define the accessModes of the PVC, if it's single can be defined as a string, multiple as a list                                 |
| persistence.[volume-name].size                                                 |   `string`    |       ❌        |         ✅         | pvc: `{{ .Values.global.fallbackDefaults.pvcSize }}` emptyDir: `""` | Define the size of the PVC, or the sizeLimit of the emptyDir                                                                     |
| persistence.[volume-name].volumeName                                           |   `string`    |       ❌        |         ✅         |                                                                     | Define the volumeName of a PV, backing the claim                                                                                 |
| persistence.[volume-name].existingClaim                                        |   `string`    |       ❌        |         ✅         |                                                                     | Define an existing claim to use                                                                                                  |
| persistence.[volume-name].storageClassName                                     |   `string`    |       ❌        |         ✅         |          See `templates/lib/storage/_storageClassName.tpl`          | Define an existing claim to use                                                                                                  |
| persistence.[volume-name].targetSelectAll                                      |   `boolean`   |       ❌        |         ❌         |                               `false`                               | Define wether to define this volume to all workloads and mount it on all containers                                              |
| persistence.[volume-name].targetSelector                                       |    `dict`     |       ❌        |         ❌         |                                `{}`                                 | Define a dict with pod and containers to mount                                                                                   |
| persistence.[volume-name].mountPath                                            |   `string`    |       ❌        |         ✅         |                                `""`                                 | Default mountPath for all container                                                                                              |
| persistence.[volume-name].path                                                 |   `string`    | ✅(On nfs type) |         ✅         |                                `""`                                 | Define the nfs export share path                                                                                                 |
| persistence.[volume-name].server                                               |   `string`    | ✅(On nfs type) |         ✅         |                                `""`                                 | Define the nfs server                                                                                                            |
| persistence.[volume-name].medium                                               |   `string`    |       ❌        |         ✅         |                                `""`                                 | Define the medium of emptyDir (Memory, "")                                                                                       |
| persistence.[volume-name].targetSelector.[pod-name]                            |    `dict`     |       ❌        |         ❌         |                                `{}`                                 | Define a dict named after the pod to define the volume                                                                           |
| persistence.[volume-name].targetSelector.[pod-name].[container-name]           |    `dict`     |       ❌        |         ❌         |                                `{}`                                 | Define a dict named after the container to mount the volume                                                                      |
| persistence.[volume-name].targetSelector.[pod-name].[container-name].mountPath |   `string`    |       ❌        |         ✅         |                      `[volume-name].mountPath`                      | Define the mountPath for the container                                                                                           |

---

Appears in:

- `.Values.persistence`

---

Naming scheme:

- `$FullName-$PersistenceName` (release-name-chart-name-PersistenceName)

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

  nfs-vol:
    enabled: true
    type: nfs
    path: /path/of/nfs/share
    server: nfs-server

  emptyDir-vol:
    enabled: true
    type: emptyDir
    medium: Memory
    size: 2Gi
```
