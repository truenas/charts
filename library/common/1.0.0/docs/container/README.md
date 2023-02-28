# Container

Assume every key below has a prefix of `workload.[workload-name].podSpec`.

| Key                                       |   Type    | Required | Helm Template | Default | Description                       |
| :---------------------------------------- | :-------: | :------: | :-----------: | :-----: | :-------------------------------- |
| containers.[container-name]               |  `dict`   |    ✅    |      ❌       |  `{}`   | Define the container as dict      |
| containers.[container-name].enabled       | `boolean` |    ✅    |      ❌       | `false` | Enables or Disables the container |
| containers.[container-name].imageSelector | `string`  |    ✅    |      ✅       | `image` | Defines the image dict to use     |
| containers.[container-name].primary       | `boolean` |    ✅    |      ❌       | `false` | Sets the container as primary     |
| containers.[container-name].stdin         | `boolean` |    ❌    |      ❌       | `false` | whether to enable stdin or not    |
| containers.[container-name].tty           | `boolean` |    ❌    |      ❌       | `false` | whether to enable tty or not      |

---

Appears in:

- `.Values.workload.[workload-name].podSpec.containers.[container-name]`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$ContainerName` (release-name-chart-name-container-name)

---

More keys for `container` can be found below:

- [command](command.md)
- [args](args.md)
- [termination](termination.md)
- [lifecycle](lifecycle.md)
- [probes](probes.md)
- [resources](resources.md)
- [securityContext](securityContext.md)
- [envFrom](envFrom.md)
- [fixedEnv](fixedEnv.md)
- [env](env.md)
- [envList](envList.md)

---

Examples:

```yaml
workload:
  workload-name:
    enabled: true
    primary: true
    podSpec:
      containers:
        container-name:
          enabled: true
          primary: true
          imageSelector: image
          stdin: true
          tty: true
```

## InitContainer

| Key                                     |   Type    | Required | Helm Template | Default | Description                                            |
| :-------------------------------------- | :-------: | :------: | :-----------: | :-----: | :----------------------------------------------------- |
| initContainers.[container-name]         |  `dict`   |    ✅    |      ❌       |  `{}`   | Define the initContainer as dict                       |
| initContainers.[container-name].enabled | `boolean` |    ✅    |      ✅       | `false` | Enables or Disables the initContainer                  |
| initContainers.[container-name].type    | `string`  |    ✅    |      ✅       |  `{}`   | Define the type initContainer (init, install, upgrade) |

> Supports all keys from [container](container.md)
> Does not use `primary` key, `lifecycle` key and `probes` key

---

Notes:

`init` type run before the containers is started.
`install` type run before the containers is started and only on install.
`upgrade` type run before the containers is started and only on upgrade.

---

Examples:

```yaml
workload:
  workload-name:
    enabled: true
    primary: true
    podSpec:
      initContainers:
        container-name:
          enabled: true
          # ...
```
