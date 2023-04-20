# Scale External Interface

| Key                                                    |   Type    |            Required             | Helm Template | Default | Description                                                                     |
| :----------------------------------------------------- | :-------: | :-----------------------------: | :-----------: | :-----: | :------------------------------------------------------------------------------ |
| scaleExternalInterface                                 |  `list`   |               ❌                |      ❌       |  `[]`   | Define the external interfaces as list                                          |
| scaleExternalInterface.targetSelectAll                 | `boolean` |               ❌                |      ❌       | `false` | Whether to add the annotation for this external interface to all workloads      |
| scaleExternalInterface.targetSelector                  |  `list`   |               ❌                |      ❌       |  `[]`   | Which workloads to add the annotations                                          |
| scaleExternalInterface.hostInterface                   | `string`  |               ✅                |      ❌       |  `""`   | Define the hostInterface, (options in GUI populated from Middleware references) |
| scaleExternalInterface.ipam                            |  `dict`   |               ✅                |      ❌       |  `{}`   | Define the ipam                                                                 |
| scaleExternalInterface.ipam.type                       | `string`  |               ✅                |      ❌       |  `""`   | Define the ipam type (dchp, static)                                             |
| scaleExternalInterface.ipam.staticIPConfiguration      |  `list`   | ✅ (Only when static ipam type) |      ❌       |  `[]`   | Define static IP Configuration (Only with static ipam type)                     |
| scaleExternalInterface.ipam.staticIPConfiguration.[IP] | `string`  |               ✅                |      ❌       |  `""`   | Define the static IP (Only with static ipam type)                               |
| scaleExternalInterface.ipam.staticRoutes               |  `list`   |               ❌                |      ❌       |  `[]`   | Define static routes (Only with static ipam type)                               |
| scaleExternalInterface.ipam.staticRoutes.destination   | `string`  |               ✅                |      ❌       |  `""`   | Define the static destination (Only with static ipam type)                      |
| scaleExternalInterface.ipam.staticRoutes.gateway       | `string`  |               ✅                |      ❌       |  `""`   | Define the static gateway (Only with static ipam type)                          |

> When `targetSelectAll` is `true`, it will add the annotations to all pods (`targetSelector` is ignored in this case)
> When `targetSelector` is a list, each entry is a string, with the pod name that will add the annotations. Can have multiple entries.
> When `targetSelector` is a empty, it will add the annotations to the primary pod

---

Appears in:

- `.Values.scaleExternalInterface`

---

Naming scheme:

- `ix-$ReleaseName-$index` (ix-release-name-0)

---

Examples:

```yaml
scaleExternalInterface:
  - hostInterface: ""
    ipam:
      type: ""
      staticRoutes: []
      staticIPConfigurations: []
    # targetSelectAll: false
    targetSelector:
      - workload-name
```
