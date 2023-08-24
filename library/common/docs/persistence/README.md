# Persistence

| Key                                                                                   |   Type    | Required | Helm Template |                     Default                      | Description                                                                                                          |
| :------------------------------------------------------------------------------------ | :-------: | :------: | :-----------: | :----------------------------------------------: | :------------------------------------------------------------------------------------------------------------------- |
| persistence                                                                           |  `dict`   |    ❌    |      ❌       |                       `{}`                       | Define the persistence as dicts                                                                                      |
| persistence.[volume-name]                                                             |  `dict`   |    ✅    |      ❌       |                       `{}`                       | Holds persistence definition                                                                                         |
| persistence.[volume-name].enabled                                                     | `boolean` |    ✅    |      ❌       |                     `false`                      | Enables or Disables the persistence                                                                                  |
| persistence.[volume-name].type                                                        | `string`  |    ❌    |      ❌       | `{{ .Values.fallbackDefaults.persistenceType }}` | Define the persistence type (ixVolume, hostPath, configmap, secret, device, pvc, ix-zfs-pvc, smb-pv-pvc, nfs-pv-pvc) |
| persistence.[volume-name].mountPath                                                   | `string`  |    ✅    |      ✅       |                       `""`                       | Default mountPath for all containers that are selected                                                               |
| persistence.[volume-name].mountPropagation                                            | `string`  |    ❌    |      ✅       |                       `""`                       | Default mountPropagation for all containers that are selected                                                        |
| persistence.[volume-name].subPath                                                     | `string`  |    ❌    |      ✅       |                       `""`                       | Default subPath for all containers that are selected                                                                 |
| persistence.[volume-name].readOnly                                                    | `boolean` |    ❌    |      ❌       |                     `false`                      | Default readOnly for all containers that are selected                                                                |
| persistence.[volume-name].targetSelectAll                                             | `boolean` |    ❌    |      ❌       |                     `false`                      | Define wether to define this volume to all workloads and mount it on all containers                                  |
| persistence.[volume-name].targetSelector                                              |  `dict`   |    ❌    |      ❌       |                       `{}`                       | Define a dict with pod and containers to mount                                                                       |
| persistence.[volume-name].targetSelector.[pod-name]                                   |  `dict`   |    ❌    |      ❌       |                       `{}`                       | Define a dict named after the pod to define the volume                                                               |
| persistence.[volume-name].targetSelector.[pod-name].[container-name]                  |  `dict`   |    ❌    |      ❌       |                       `{}`                       | Define a dict named after the container to mount the volume                                                          |
| persistence.[volume-name].targetSelector.[pod-name].[container-name].mountPath        | `string`  |    ❌    |      ✅       |            `[volume-name].mountPath`             | Define the mountPath for the container                                                                               |
| persistence.[volume-name].targetSelector.[pod-name].[container-name].mountPropagation | `string`  |    ❌    |      ✅       |         `[volume-name].mountPropagation`         | Define the mountPropagation for the container                                                                        |
| persistence.[volume-name].targetSelector.[pod-name].[container-name].subPath          | `string`  |    ❌    |      ✅       |             `[volume-name].subPath`              | Define the subPath for the container                                                                                 |
| persistence.[volume-name].targetSelector.[pod-name].[container-name].readOnly         | `boolean` |    ❌    |      ❌       |             `[volume-name].readOnly`             | Define the readOnly for the container                                                                                |

> When `targetSelectAll` is `true`, it will define the volume to all pods and volumeMount to all containers (`targetSelector` is ignored in this case)
> When `targetSelector` is defined, it will define the volume to the pod(s) and volumeMount to the container(s) selected. See below for the selector structure.
> When `targetSelector` is a empty, it will define the volume to the primary pod and volumeMount to the primary container
> `targetSelectAll` is only useful when you want to mount a shared volume to all pods and containers.
> Otherwise, you should use `targetSelector` to define the volume to specific pods and containers.

---

Appears in:

- `.Values.persistence`

---

Naming scheme:

- `$FullName-$PersistenceName` (release-name-chart-name-PersistenceName)

---

> Those are the common `keys` for all **persistence**.
> Additional keys, information and examples, see on the specific kind of persistence.

- [configmap](configmap.md)
- [emptyDir](emptyDir.md)
- [ixVolume](ixVolume.md)
- [hostPath](hostPath.md)
- [device](device.md)
- [secret](secret.md)
- [pvc](pvc.md)
- [ix-zfs-pvc](ix-zfs-pvc.md)
- [smb-pv-pvc](smb-pv-pvc.md)
- [nfs-pv-pvc](nfs-pv-pvc.md)

---

Examples:

```yaml
# Example of a shared emptyDir volume
persistence:
  shared:
    enabled: true
    type: emptyDir
    mountPath: /shared
    readOnly: false
    targetSelectAll: true
```

```yaml
# Example of a volume mounted to a specific container with a specific mountPath
persistence:
  config:
    enabled: true
    type: emptyDir
    targetSelector:
      my-pod:
        my-container: {}
          mountPath: /path
          readOnly: false
        my-other-container: {}
          mountPath: /other/path
          readOnly: false
```

```yaml
# Example of a volume mounted to a specific container using the default mountPath
persistence:
  config:
    enabled: true
    type: emptyDir
    mountPath: /path
    readOnly: true
    targetSelector:
      my-pod:
        my-container: {}
        my-other-container:
          mountPath: /other/path
          readOnly: false
```
