# Probes

| Key                         |  Type   | Helm Template |  Default  | Description                                    |
| :-------------------------- | :-----: | :-----------: | :-------: | :--------------------------------------------- |
| probes                      | object  |      Yes      | See below | [probes](#probes)                              |
| probes.[probe-name]         | object  |      Yes      | See below | Allowed values: readiness / liveness / startup |
| probes.[probe-name].enabled | boolean |      Yes      |  `true`   | Enables or Disables the probe                  |
| probes.[probe-name].type    | string  |      Yes      |  `auto`   | [types](#types)                                |
| probes.[probe-name].spec    | object  |      Yes      | See below | Contains timeout values                        |

Default probes:

```yaml
probes:
  liveness:
    enabled: true
    type: auto
    spec:
      initialDelaySeconds: 10
      failureThreshold: 5
      timeoutSeconds: 5
      periodSeconds: 10
  readiness:
    enabled: true
    type: auto
    spec:
      initialDelaySeconds: 10
      failureThreshold: 5
      timeoutSeconds: 5
      periodSeconds: 10
  startup:
    enabled: true
    type: auto
    spec:
      initialDelaySeconds: 10
      failureThreshold: 60
      timeoutSeconds: 2
      periodSeconds: 5
```

> `auto` type is only available for the main container.

## probes

Can be defined in:

- `.Values`.probes
- `.Values.additionalContainers.[container-name]`.probes

### spec

| Key                                       | Type | Helm Template | Default | Description |
| :---------------------------------------- | :--: | :-----------: | :-----: | :---------- |
| probes.liveness.spec.initialDelaySeconds  | int  |      Yes      |   10    |             |
| probes.liveness.spec.failureThreshold     | int  |      Yes      |    5    |             |
| probes.liveness.spec.timeoutSeconds       | int  |      Yes      |    5    |             |
| probes.liveness.spec.periodSeconds        | int  |      Yes      |   10    |             |
| probes.readiness.spec.initialDelaySeconds | int  |      Yes      |   10    |             |
| probes.startup.spec.initialDelaySeconds   | int  |      Yes      |   10    |             |
| probes.startup.spec.failureThreshold      | int  |      Yes      |   60    |             |
| probes.startup.spec.timeoutSeconds        | int  |      Yes      |    2    |             |
| probes.startup.spec.periodSeconds         | int  |      Yes      |    5    |             |
| probes.readiness.spec.failureThreshold    | int  |      Yes      |    5    |             |
| probes.readiness.spec.timeoutSeconds      | int  |      Yes      |    5    |             |
| probes.readiness.spec.periodSeconds       | int  |      Yes      |   10    |             |

`spec` contains the timeouts for the probe.
If not defined it will use the defaults from `.Values.global.defaults.probes.[probe-name].spec`.

## Types

Allowed values: auto / http / https / tcp / grpc / exec / custom

### http / https

| Key                             |  Type  | Helm Template | Default | Description                  |
| :------------------------------ | :----: | :-----------: | :-----: | :--------------------------- |
| probes.[probe-name].port        |  int   |      Yes      |  unset  | Sets the probe's port        |
| probes.[probe-name].path        | string |      Yes      |   `/`   | Sets the probe's path        |
| probes.[probe-name].httpHeaders | object |      Yes      |  `{}`   | Sets the probe's httpHeaders |

> If type is set to `auto`, `port` defaults the the primary service's targetPort,
> if not `targetPort` is defined, fail-backs to `port`
> scheme is set based on the `type` (http / https)

Example:

```yaml
probes:
  probe-name:
    enabled: true
    type: http
    path: "/"
    port: 80
    httpHeaders: {}
    spec:
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 5
```

---

### tcp

| Key                      | Type | Helm Template | Default | Description           |
| :----------------------- | :--: | :-----------: | :-----: | :-------------------- |
| probes.[probe-name].port | int  |      Yes      |  unset  | Sets the probe's port |

> If type is set to `auto`, `port` defaults the the primary service's targetPort,
> if not `targetPort` is defined, fail-backs to `port`

Example:

```yaml
probes:
  probe-name:
    enabled: true
    type: tcp
    port: 80
    spec:
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 5
```

### grpc

| Key                      | Type | Helm Template | Default | Description           |
| :----------------------- | :--: | :-----------: | :-----: | :-------------------- |
| probes.[probe-name].grpc | int  |      Yes      |  unset  | Sets the probe's port |

> If type is set to `auto`, `port` defaults the the primary service's targetPort,
> if not `targetPort` is defined, fail-backs to `port`

Example:

```yaml
probes:
  probe-name:
    enabled: true
    type: grpc
    port: 80
    spec:
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 5
```

### exec

| Key                         |    Type     | Helm Template | Default | Description                        |
| :-------------------------- | :---------: | :-----------: | :-----: | :--------------------------------- |
| probes.[probe-name].command | list/string |      Yes      |  `{}`   | [command](command-args.md#command) |

Example:

```yaml
probes:
  probe-name:
    enabled: true
    type: exec
    command:
      - /bin/sh
      - -c
      - |
        curl ...
    spec:
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 5
```
