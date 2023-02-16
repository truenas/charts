# Volume Claim Template

| Key                                                                                         |     Type      | Required |   Helm Template    |                        Default                         | Description                                                                                      |
| :------------------------------------------------------------------------------------------ | :-----------: | :------: | :----------------: | :----------------------------------------------------: | :----------------------------------------------------------------------------------------------- |
| volumeClaimTemplates                                                                        |    `dict`     |    ❌    |         ❌         |                          `{}`                          | Define the VCT as dicts                                                                          |
| volumeClaimTemplates.[vct-name]                                                             |    `dict`     |    ✅    |         ❌         |                          `{}`                          | Holds VCT definition                                                                             |
| volumeClaimTemplates.[vct-name].enabled                                                     |   `boolean`   |    ✅    |         ❌         |                        `false`                         | Enables or Disables the VCT                                                                      |
| volumeClaimTemplates.[vct-name].labels                                                      |    `dict`     |    ❌    | ✅ (On value only) |                          `{}`                          | Labels for the VCT                                                                               |
| volumeClaimTemplates.[vct-name].annotations                                                 |    `dict`     |    ❌    | ✅ (On value only) |                          `{}`                          | Annotations for the VCT                                                                          |
| volumeClaimTemplates.[vct-name].size                                                        |   `string`    |    ❌    |         ✅         |    `{{ .Values.global.fallbackDefaults.pvcSize }}`     | Define the size of the PVC                                                                       |
| volumeClaimTemplates.[vct-name].accessModes                                                 | `string/list` |    ❌    |         ✅         | `{{ .Values.global.fallbackDefaults.pvcAccessModes }}` | Define the accessModes of the PVC, if it's single can be defined as a string, multiple as a list |
| volumeClaimTemplates.[vct-name].storageClassName                                            |   `string`    |    ❌    |         ✅         |                       See below                       | Define an existing claim to use                                                                  |
| volumeClaimTemplates.[vct-name].mountPath                                                   |   `string`    |    ✅    |         ✅         |                          `""`                          | Default mountPath for all containers that are selected                                           |
| volumeClaimTemplates.[vct-name].mountPropagation                                            |   `string`    |    ❌    |         ✅         |                          `""`                          | Default mountPropagation for all containers that are selected                                    |
| volumeClaimTemplates.[vct-name].subPath                                                     |   `string`    |    ❌    |         ✅         |                          `""`                          | Default subPath for all containers that are selected                                             |
| volumeClaimTemplates.[vct-name].readOnly                                                    |   `boolean`   |    ❌    |         ❌         |                        `false`                         | Default readOnly for all containers that are selected                                            |
| volumeClaimTemplates.[vct-name].targetSelector                                              |    `dict`     |    ❌    |         ❌         |                          `{}`                          | Define a dict with pod and containers to mount                                                   |
| volumeClaimTemplates.[vct-name].targetSelector.[pod-name]                                   |    `dict`     |    ❌    |         ❌         |                          `{}`                          | Define a dict named after the pod to define the volume                                           |
| volumeClaimTemplates.[vct-name].targetSelector.[pod-name].[container-name]                  |    `dict`     |    ❌    |         ❌         |                          `{}`                          | Define a dict named after the container to mount the volume                                      |
| volumeClaimTemplates.[vct-name].targetSelector.[pod-name].[container-name].mountPath        |   `string`    |    ❌    |         ✅         |                 `[vct-name].mountPath`                 | Define the mountPath for the container                                                           |
| volumeClaimTemplates.[vct-name].targetSelector.[pod-name].[container-name].mountPropagation |   `string`    |    ❌    |         ✅         |             `[vct-name].mountPropagation`              | Define the mountPropagation for the container                                                    |
| volumeClaimTemplates.[vct-name].targetSelector.[pod-name].[container-name].subPath          |   `string`    |    ❌    |         ✅         |                  `[vct-name].subPath`                  | Define the subPath for the container                                                             |
| volumeClaimTemplates.[vct-name].targetSelector.[pod-name].[container-name].readOnly         |   `boolean`   |    ❌    |         ❌         |                 `[vct-name].readOnly`                  | Define the readOnly for the container                                                            |

> When `targetSelector` is a empty, it will define the volume to the primary pod and volumeMount to the primary container
> When `targetSelector` is defined, referencing pod(s) and container(s) it will define the volume to those pod(s) and volumeMount to those container(s)

---

Appears in:

- `.Values.volumeClaimTemplates`

---

Naming scheme:

- `$FullName-$VolumeClaimTemplateName` (release-name-chart-name-VolumeClaimTemplateName)

---

Examples:

```yaml
# Example of a shared emptyDir volume
volumeClaimTemplates:
  vct-name:
    enabled: true
    mountPath: /shared
    readOnly: false
    targetSelectAll: true
```

```yaml
# Example of a volume mounted to a specific container with a specific mountPath
volumeClaimTemplates:
  db-data:
    enabled: true
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
  db-data:
    enabled: true
    mountPath: /path
    readOnly: true
    targetSelector:
      my-pod:
        my-container: {}
        my-other-container:
          mountPath: /other/path
          readOnly: false
```
