# Scale GPU

| Key                                                 |   Type   | Required | Helm Template | Default | Description                                   |
| :-------------------------------------------------- | :------: | :------: | :-----------: | :-----: | :-------------------------------------------- |
| scaleGPU                                            |  `list`  |    ❌    |      ❌       |  `[]`   | Define the external interfaces as list        |
| scaleGPU.targetSelector                             |  `dict`  |    ❌    |      ❌       |  `{}`   | Where to assign the GPU                       |
| scaleGPU.targetSelector.[pod-name]                  |  `list`  |    ❌    |      ❌       |  `[]`   | The workload to select                             |
| scaleGPU.targetSelector.[pod-name].[container-name] | `string` |    ✅    |      ❌       |  `""`   | The container to select                       |
| scaleGPU.gpu                                        |  `dict`  |    ✅    |      ❌       |  `{}`   | The GPU key value pair to define in resources |

> When `targetSelector` is a dict, each entry is a list, containing the name(s) of the container(s) to assign the GPU
> When `targetSelector` is a empty, it will assign the GPU to the primary pod/container
> Selected pod's will get appended the group `44` and `107` in `supplementalGroups`. This is to allow rootless containers to access the GPU

---

Appears in:

- `.Values.scaleGPU`

---

Examples:

```yaml
scaleGPU:
  - gpu:
      # Injected from SCALE UI/Middleware using $ref
      nvidia.com/gpu: "1"
    targetSelector:
      workload-name:
        - container-name
```
