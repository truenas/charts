# Persistence

| Key                                                                            |   Type    | Required | Helm Template |          Default          | Description                                                                           |
| :----------------------------------------------------------------------------- | :-------: | :------: | :-----------: | :-----------------------: | :------------------------------------------------------------------------------------ |
| persistence                                                                    |  `dict`   |    ❌    |      ❌       |           `{}`            | Define the persistence as dicts                                                       |
| persistence.[volume-name]                                                      |  `dict`   |    ✅    |      ❌       |           `{}`            | Holds persistence definition                                                          |
| persistence.[volume-name].enabled                                              | `boolean` |    ✅    |      ❌       |          `false`          | Enables or Disables the persistence                                                   |
| persistence.[volume-name].type                                                 | `string`  |    ❌    |      ❌       |           `pvc`           | Define the persistence type (pvc, ixVolume, nfs, hostPath, configmap, secret, device) |
| persistence.[volume-name].targetSelectAll                                      | `boolean` |    ❌    |      ❌       |          `false`          | Define wether to define this volume to all workloads and mount it on all containers   |
| persistence.[volume-name].targetSelector                                       |  `dict`   |    ❌    |      ❌       |           `{}`            | Define a dict with pod and containers to mount                                        |
| persistence.[volume-name].mountPath                                            | `string`  |    ❌    |      ✅       |           `""`            | Default mountPath for all container                                                   |
| persistence.[volume-name].targetSelector.[pod-name]                            |  `dict`   |    ❌    |      ❌       |           `{}`            | Define a dict named after the pod to define the volume                                |
| persistence.[volume-name].targetSelector.[pod-name].[container-name]           |  `dict`   |    ❌    |      ❌       |           `{}`            | Define a dict named after the container to mount the volume                           |
| persistence.[volume-name].targetSelector.[pod-name].[container-name].mountPath | `string`  |    ❌    |      ✅       | `[volume-name].mountPath` | Define the mountPath for the container                                                |

> When `targetSelectAll` is `true`, it will define the volume to all pods (`targetSelector` is ignored in this case)
> When `targetSelector` is defined, referencing pod(s) it will define the volume to those pod(s)
> When `targetSelector` is a empty, it will define the volume to the primary pod

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
- [nfs](nfs.md)
