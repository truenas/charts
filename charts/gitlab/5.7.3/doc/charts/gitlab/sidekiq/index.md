---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the GitLab-Sidekiq chart **(FREE SELF)**

The `sidekiq` sub-chart provides configurable deployment of Sidekiq workers, explicitly
designed to provide separation of queues across multiple `Deployment`s with individual
scalability and configuration.

While this chart provides a default `pods:` declaration, if you provide an empty definition,
you will have *no* workers.

## Requirements

This chart depends on access to Redis, PostgreSQL, and Gitaly services, either as
part of the complete GitLab chart or provided as external services reachable from
the Kubernetes cluster this chart is deployed onto.

## Design Choices

This chart creates multiple `Deployment`s and associated `ConfigMap`s. It was decided
that it would be clearer to make use of `ConfigMap` behaviours instead of using `environment`
attributes or additional arguments to the `command` for the containers, in order to
avoid any concerns about command length. This choice results in a large number of
`ConfigMap`s, but provides very clear definitions of what each pod should be doing.

## Configuration

The `sidekiq` chart is configured in three parts: chart-wide [external services](#external-services),
[chart-wide defaults](#chart-wide-defaults), and [per-pod definitions](#per-pod-settings).

## Installation command line options

The table below contains all the possible charts configurations that can be supplied
to the `helm install` command using the `--set` flags:

| Parameter                            | Default           | Description                              |
| ------------------------------------ | ----------------- | ---------------------------------------- |
| `annotations`                        |                   | Pod annotations                          |
| `podLabels`                          |                   | Supplemental Pod labels. Will not be used for selectors. |
| `common.labels`                      |                   | Supplemental labels that are applied to all objects created by this chart. |
| `concurrency`                        | `25`              | Sidekiq default concurrency              |
| `deployment.strategy`                | `{}`              | Allows one to configure the update strategy utilized by the deployment |
| `deployment.terminationGracePeriodSeconds` | `30`        | Optional duration in seconds the pod needs to terminate gracefully. |
| `enabled`                            | `true`            | Sidekiq enabled flag                     |
| `extraContainers`                    |                   | List of extra containers to include      |
| `extraInitContainers`                |                   | List of extra init containers to include |
| `extraVolumeMounts`                  |                   | String template of extra volume mounts to configure |
| `extraVolumes`                       |                   | String template of extra volumes to configure |
| `extraEnv`                           |                   | List of extra environment variables to expose |
| `gitaly.serviceName`                 | `gitaly`          | Gitaly service name                      |
| `hpa.targetAverageValue`             | `350m`            | Set the autoscaling target value         |
| `minReplicas`                        | `2`               | Minimum number of replicas               |
| `maxReplicas`                        | `10`              | Maximum number of replicas               |
| `maxUnavailable`                     | `1`               | Limit of maximum number of Pods to be unavailable |
| `image.pullPolicy`                   | `Always`          | Sidekiq image pull policy                |
| `image.pullSecrets`                  |                   | Secrets for the image repository         |
| `image.repository`                   | `registry.gitlab.com/gitlab-org/build/cng/gitlab-sidekiq-ee` | Sidekiq image repository |
| `image.tag`                          |                   | Sidekiq image tag                        |
| `init.image.repository`              |                   | initContainer image                      |
| `init.image.tag`                     |                   | initContainer image tag                  |
| `logging.format`                     | `default`         | Set to `json` for JSON-structured logs   |
| `metrics.enabled`                    | `true`            | Toggle Prometheus metrics exporter       |
| `psql.password.key`                  | `psql-password`   | key to psql password in psql secret      |
| `psql.password.secret`               | `gitlab-postgres` | psql password secret                     |
| `psql.port`                          |                   | Set PostgreSQL server port. Takes precedence over `global.psql.port` |
| `redis.serviceName`                  | `redis`           | Redis service name                       |
| `resources.requests.cpu`             | `900m`            | Sidekiq minimum needed CPU               |
| `resources.requests.memory`          | `2G`              | Sidekiq minimum needed memory            |
| `resources.limits.memory`            |                   | Sidekiq maximum allowed memory           |
| `timeout`                            | `25`              | Sidekiq job timeout                      |
| `tolerations`                        | `[]`              | Toleration labels for pod assignment     |
| `memoryKiller.daemonMode`            | `true`            | If `false`, uses the legacy memory killer mode |
| `memoryKiller.maxRss`                | `2000000`         | Maximum RSS before delayed shutdown triggered expressed in kilobytes |
| `memoryKiller.graceTime`             | `900`             | Time to wait before a triggered shutdown expressed in seconds|
| `memoryKiller.shutdownWait`          | `30`              | Amount of time after triggered shutdown for existing jobs to finish expressed in seconds |
| `memoryKiller.hardLimitRss`          |                   | Maximum RSS before immediate shutdown triggered expressed in kilobyte in daemon mode |
| `memoryKiller.checkInterval`         | `3`               | Amount of time between memory checks     |
| `livenessProbe.initialDelaySeconds`  | 20                | Delay before liveness probe is initiated                                                              |
| `livenessProbe.periodSeconds`        | 60                | How often to perform the liveness probe                                                               |
| `livenessProbe.timeoutSeconds`       | 30                | When the liveness probe times out                                                                     |
| `livenessProbe.successThreshold`     | 1                 | Minimum consecutive successes for the liveness probe to be considered successful after having failed  |
| `livenessProbe.failureThreshold`     | 3                 | Minimum consecutive failures for the liveness probe to be considered failed after having succeeded    |
| `readinessProbe.initialDelaySeconds` | 0                 | Delay before readiness probe is initiated                                                             |
| `readinessProbe.periodSeconds`       | 10                | How often to perform the readiness probe                                                              |
| `readinessProbe.timeoutSeconds`      | 2                 | When the readiness probe times out                                                                    |
| `readinessProbe.successThreshold`    | 1                 | Minimum consecutive successes for the readiness probe to be considered successful after having failed |
| `readinessProbe.failureThreshold`    | 3                 | Minimum consecutive failures for the readiness probe to be considered failed after having succeeded   |
| `securityContext.fsGroup`            | `1000`            | Group ID under which the pod should be started |
| `securityContext.runAsUser`          | `1000`            | User ID under which the pod should be started  |
| `priorityClassName`                  | `""`              | Allow configuring pods `priorityClassName`, this is used to control pod priority in case of eviction |

## Chart configuration examples

### resources

`resources` allows you to configure the minimum and maximum amount of resources (memory and CPU) a Sidekiq
pod can consume.

Sidekiq pod workloads vary greatly between deployments. Generally speaking, it is understood that each Sidekiq
process consumes approximately 1 vCPU and 2 GB of memory. Vertical scaling should generally align to this `1:2`
ratio of `vCPU:Memory`.

Below is an example use of `resources`:

```yaml
resources:
  limits:
    memory: 5G
  requests:
    memory: 2G
    cpu: 900m
```

### extraEnv

`extraEnv` allows you to expose additional environment variables in the dependencies container.

Below is an example use of `extraEnv`:

```yaml
extraEnv:
  SOME_KEY: some_value
  SOME_OTHER_KEY: some_other_value
```

When the container is started, you can confirm that the environment variables are exposed:

```shell
env | grep SOME
SOME_KEY=some_value
SOME_OTHER_KEY=some_other_value
```

You can also set `extraEnv` for a specific pod:

```yaml
extraEnv:
  SOME_KEY: some_value
  SOME_OTHER_KEY: some_other_value
pods:
  - name: mailers
    queues: mailers
    extraEnv:
      SOME_POD_KEY: some_pod_value
  - name: catchall
    negateQueues: mailers
```

This will set `SOME_POD_KEY` only for application containers in the `mailers`
pod. Pod-level `extraEnv` settings are not added to [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/).

### extraVolumes

`extraVolumes` allows you to configure extra volumes chart-wide.

Below is an example use of `extraVolumes`:

```yaml
extraVolumes: |
  - name: example-volume
    persistentVolumeClaim:
      claimName: example-pvc
```

### extraVolumeMounts

`extraVolumeMounts` allows you to configure extra volumeMounts on all containers chart-wide.

Below is an example use of `extraVolumeMounts`:

```yaml
extraVolumeMounts: |
  - name: example-volume-mount
    mountPath: /etc/example
```

### image.pullSecrets

`pullSecrets` allows you to authenticate to a private registry to pull images for a pod.

Additional details about private registries and their authentication methods can be
found in [the Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`:

```yaml
image:
  repository: my.sidekiq.repository
  pullPolicy: Always
  pullSecrets:
  - name: my-secret-name
  - name: my-secondary-secret-name
```

### tolerations

`tolerations` allow you schedule pods on tainted worker nodes

Below is an example use of `tolerations`:

```yaml
tolerations:
- key: "node_label"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
- key: "node_label"
  operator: "Equal"
  value: "true"
  effect: "NoExecute"
```

### annotations

`annotations` allows you to add annotations to the Sidekiq pods.

Below is an example use of `annotations`:

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```

## Using the Community Edition of this chart

By default, the Helm charts use the Enterprise Edition of GitLab. If desired, you
can use the Community Edition instead. Learn more about the
[differences between the two](https://about.gitlab.com/install/ce-or-ee/).

In order to use the Community Edition, set `image.repository` to
`registry.gitlab.com/gitlab-org/build/cng/gitlab-sidekiq-ce`.

## External Services

This chart should be attached to the same Redis, PostgreSQL, and Gitaly instances
as the Webservice chart. The values of external services will be populated into a `ConfigMap`
that is shared across all Sidekiq pods.

### Redis

```yaml
redis:
  host: rank-racoon-redis
  port: 6379
  sentinels:
    - host: sentinel1.example.com
      port: 26379
  password:
    secret: gitlab-redis
    key: redis-password
```

| Name               | Type    | Default | Description |
|:------------------ |:-------:|:------- |:----------- |
| `host`             | String  |         | The hostname of the Redis server with the database to use. This can be omitted in lieu of `serviceName`. If using Redis Sentinels, the `host` attribute needs to be set to the cluster name as specified in the `sentinel.conf`. |
| `password.key`     | String  |         | The `password.key` attribute for Redis defines the name of the key in the secret (below) that contains the password. |
| `password.secret`  | String  |         | The `password.secret` attribute for Redis defines the name of the Kubernetes `Secret` to pull from. |
| `port`             | Integer | `6379`  | The port on which to connect to the Redis server. |
| `serviceName`      | String  | `redis` | The name of the `service` which is operating the Redis database. If this is present, and `host` is not, the chart will template the hostname of the service (and current `.Release.Name`) in place of the `host` value. This is convenient when using Redis as a part of the overall GitLab chart. |
| `sentinels.[].host`| String  |         | The hostname of Redis Sentinel server for a Redis HA setup. |
| `sentinels.[].port`| Integer | `26379` | The port on which to connect to the Redis Sentinel server. |

_Note:_ The current Redis Sentinel support only supports Sentinels that have
been deployed separately from the GitLab chart. As a result, the Redis
deployment through the GitLab chart should be disabled with `redis.install=false`.
The Secret containing the Redis password will need to be manually created
before deploying the GitLab chart.

### PostgreSQL

```yaml
psql:
  host: rank-racoon-psql
  serviceName: pgbouncer
  port: 5432
  database: gitlabhq_production
  username: gitlab
  preparedStatements: false
  password:
    secret: gitlab-postgres
    key: psql-password
```

| Name              | Type    | Default               | Description |
|:----------------  |:-------:|:--------------------- |:----------- |
| `host`            | String  |                       | The hostname of the PostgreSQL server with the database to use. This can be omitted if `postgresql.install=true` (default non-production). |
| `serviceName`     | String  |                       | The name of the `service` which is operating the PostgreSQL database. If this is present, and `host` is not, the chart will template the hostname of the service in place of the `host` value. |
| `database`        | String  | `gitlabhq_production` | The name of the database to use on the PostgreSQL server. |
| `password.key`    | String  |                       | The `password.key` attribute for PostgreSQL defines the name of the key in the secret (below) that contains the password. |
| `password.secret` | String  |                       | The `password.secret` attribute for PostgreSQL defines the name of the Kubernetes `Secret` to pull from. |
| `port`            | Integer | `5432`                | The port on which to connect to the PostgreSQL server. |
| `username`        | String  | `gitlab`              | The username with which to authenticate to the database. |
| `preparedStatements`| Boolean  | `false`               | If prepared statements should be used when communicating with the PostgreSQL server. |

### Gitaly

```YAML
gitaly:
  internal:
    names:
      - default
      - default2
  external:
    - name: node1
      hostname: node1.example.com
      port: 8079
  authToken:
    secret: gitaly-secret
    key: token
```

| Name               | Type    | Default  | Description |
|:-----------------  |:-------:|:-------- |:----------- |
| `host`             | String  |          | The hostname of the Gitaly server to use. This can be omitted in lieu of `serviceName`. |
| `serviceName`      | String  | `gitaly` | The name of the `service` which is operating the Gitaly server. If this is present, and `host` is not, the chart will template the hostname of the service (and current `.Release.Name`) in place of the `host` value. This is convenient when using Gitaly as a part of the overall GitLab chart. |
| `port`             | Integer | `8075`   | The port on which to connect to the Gitaly server. |
| `authToken.key`    | String  |          | The name of the key in the secret below that contains the authToken. |
| `authToken.secret` | String  |          | The name of the Kubernetes `Secret` to pull from. |

## Metrics

By default, a Prometheus metrics exporter is enabled per pod. Metrics are only available
when [GitLab Prometheus metrics](https://docs.gitlab.com/ee/administration/monitoring/prometheus/gitlab_metrics.html)
are enabled in the Admin area. The exporter exposes a `/metrics` endpoint on port
`3807`. When metrics are enabled, annotations are added to each pod allowing a Prometheus
server to discover and scrape the exposed metrics.

## Chart-wide defaults

The following values will be used chart-wide, in the event that a value is not presented
on a per-pod basis.

| Name          | Type    | Default | Description |
|:------------- |:-------:|:------- |:----------- |
| `concurrency`               | Integer | `25`      | The number of tasks to process simultaneously. |
| `timeout`                   | Integer | `4`       | The Sidekiq shutdown timeout. The number of seconds after Sidekiq gets the TERM signal before it forcefully shuts down its processes. |
| `memoryKiller.checkInterval`| Integer | `3`       | Amount of time in seconds between memory checks     |
| `memoryKiller.maxRss`       | Integer | `2000000` | Maximum RSS before delayed shutdown triggered expressed in kilobytes |
| `memoryKiller.graceTime`    | Integer | `900`     | Time to wait before a triggered shutdown expressed in seconds|
| `memoryKiller.shutdownWait` | Integer | `30`      | Amount of time after triggered shutdown for existing jobs to finish expressed in seconds |
| `minReplicas`               | Integer | `2`       | Minimum number of replicas |
| `maxReplicas`               | Integer | `10`      | Maximum number of replicas |
| `maxUnavailable`            | Integer | `1`       | Limit of maximum number of Pods to be unavailable |

NOTE:
[Detailed documentation of the Sidekiq memory killer is
available](https://docs.gitlab.com/ee/administration/operations/sidekiq_memory_killer.html#sidekiq-memorykiller)
in the Omnibus documentation.

## Per-pod Settings

The `pods` declaration provides for the declaration of all attributes for a worker
pod. These will be templated to `Deployment`s, with individual `ConfigMap`s for their
Sidekiq instances.

NOTE:
The settings default to including a single pod that is set up to monitor
all queues. Making changes to the pods section will *overwrite the default pod* with
a different pod configuration. It will not add a new pod in addition to the default.

| Name           | Type    | Default | Description |
|:-------------- |:-------:|:------- |:----------- |
| `concurrency`  | Integer |         | The number of tasks to process simultaneously. If not provided, it will be pulled from the chart-wide default. |
| `name`         | String  |         | Used to name the `Deployment` and `ConfigMap` for this pod. It should be kept short, and should not be duplicated between any two entries. |
| `queues`       | String |         | [See below](#queues). |
| `negateQueues` | String |         | [See below](#negatequeues). |
| `queueSelector` | Boolean | `false` | Use the [queue selector](https://docs.gitlab.com/ee/administration/operations/extra_sidekiq_processes.html#queue-selector). |
| `timeout`      | Integer |         | The Sidekiq shutdown timeout. The number of seconds after Sidekiq gets the TERM signal before it forcefully shuts down its processes. If not provided, it will be pulled from the chart-wide default. This value **must** be less than `terminationGracePeriodSeconds`. |
| `resources`    |         |         | Each pod can present it's own `resources` requirements, which will be added to the `Deployment` created for it, if present. These match the Kubernetes documentation. |
| `nodeSelector` |         |         | Each pod can be configured with a `nodeSelector` attribute, which will be added to the `Deployment` created for it, if present. These definitions match the Kubernetes documentation.|
| `memoryKiller.checkInterval`| Integer | `3`       | Amount of time between memory checks     |
| `memoryKiller.maxRss`       | Integer | `2000000` | Overrides the maximum RSS for a given pod. |
| `memoryKiller.graceTime`    | Integer | `900`     | Overrides the time to wait before a triggered shutdown for a given Pod |
| `memoryKiller.shutdownWait` | Integer | `30`      | Overrides the amount of time after triggered shutdown for existing jobs to finish for a given Pod |
| `minReplicas`  | Integer | `2`     | Minimum number of replicas |
| `maxReplicas`  | Integer | `10`    | Maximum number of replicas |
| `maxUnavailable` | Integer | `1`   | Limit of maximum number of Pods to be unavailable |
| `podLabels`      | `{}`  | `{}`    | Supplemental Pod labels. Will not be used for selectors. |
| `strategy` |       | `{}`    | Allows one to configure the update strategy utilized by the deployment |
| `extraVolumes` | String  |         | Configures extra volumes for the given pod. |
| `extraVolumeMounts` | String |     | Configures extra volume mounts for the given pod. |
| `priorityClassName` | String | `""` | Allow configuring pods `priorityClassName`, this is used to control pod priority in case of eviction |
| `hpa.targetAverageValue` | String |  | Overrides the autoscaling target value for the given pod. |
| `extraEnv` | Map | | List of extra environment variables to expose. The chart-wide value is merged into this, with values from the pod taking precedence |
| `terminationGracePeriodSeconds` | `30` | Optional duration in seconds the pod needs to terminate gracefully. |

### queues

The `queues` value is a string containing a comma-separated list of queues to be
processed. By default, it is not set, meaning that all queues will be processed.

The string should not contain spaces: `merge,post_receive,process_commit` will
work, but `merge, post_receive, process_commit` will not.

Any queue to which jobs are added but are not represented as a part of at least
one pod item *will not be processed*. For a complete list of all queues, see
these files in the GitLab source:

1. [`app/workers/all_queues.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/workers/all_queues.yml)
1. [`ee/app/workers/all_queues.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/workers/all_queues.yml)

### negateQueues

`negateQueues` is in the same format as [`queues`](#queues), but it represents
queues to be ignored rather than processed.

The string should not contain spaces: `merge,post_receive,process_commit` will
work, but `merge, post_receive, process_commit` will not.

This is useful if you have a pod processing important queues, and another pod
processing other queues: they can use the same list of queues, with one being in
`queues` and the other being in `negateQueues`.

NOTE:
`negateQueues` _should not_ be provided alongside `queues`, as it will have no effect.

### Example `pod` entry

```YAML
pods:
  - name: immediate
    concurrency: 10
    minReplicas: 2  # defaults to inherited value
    maxReplicas: 10 # defaults to inherited value
    maxUnavailable: 5 # defaults to inherited value
    queues: merge,post_receive,process_commit
    extraVolumeMounts: |
      - name: example-volume-mount
        mountPath: /etc/example
    extraVolumes: |
      - name: example-volume
        persistentVolumeClaim:
          claimName: example-pvc
    resources:
      limits:
        cpu: 800m
        memory: 2Gi
    hpa:
      targetAverageValue: 350m
```

## Configuring the `networkpolicy`

This section controls the
[NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
This configuration is optional and is used to limit Egress and Ingress of the
Pods to specific endpoints.

| Name              | Type    | Default | Description |
|:----------------- |:-------:|:------- |:----------- |
| `enabled`         | Boolean | `false` | This setting enables the network policy |
| `ingress.enabled` | Boolean | `false` | When set to `true`, the `Ingress` network policy will be activated. This will block all Ingress connections unless rules are specified. |
| `ingress.rules`   | Array   | `[]`    | Rules for the Ingress policy, for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |
| `egress.enabled`  | Boolean | `false` | When set to `true`, the `Egress` network policy will be activated. This will block all egress connections unless rules are specified. |
| `egress.rules`    | Array   | `[]`    | Rules for the egress policy, these for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |

### Example Network Policy

The Sidekiq service requires Ingress connections for only the Prometheus
exporter if enabled, and normally requires Egress connections to various
places. This examples adds the following network policy:

- All Ingress requests from the network on TCP `10.0.0.0/8` port 3807 are allowed for metrics exporting
- All Egress requests to the network on UDP `10.0.0.0/8` port 53 are allowed for DNS
- All Egress requests to the network on TCP `10.0.0.0/8` port 5432 are allowed for PostgreSQL
- All Egress requests to the network on TCP `10.0.0.0/8` port 6379 are allowed for Redis
- Other Egress requests to the local network on `10.0.0.0/8` are restricted
- Egress requests outside of the `10.0.0.0/8` are allowed

_Note the example provided is only an example and may not be complete_

_Note that the Sidekiq service requires outbound connectivity to the public
internet for images on [external object storage](../../../advanced/external-object-storage)_

```yaml
networkpolicy:
  enabled: true
  ingress:
    enabled: true
    rules:
      - from:
        - ipBlock:
            cidr: 10.0.0.0/8
        ports:
        - port: 3807
  egress:
    enabled: true
    rules:
      - to:
        - ipBlock:
            cidr: 10.0.0.0/8
        ports:
        - port: 53
          protocol: UDP
      - to:
        - ipBlock:
            cidr: 10.0.0.0/8
        ports:
        - port: 5432
          protocol: TCP
      - to:
        - ipBlock:
            cidr: 10.0.0.0/8
        ports:
        - port: 6379
          protocol: TCP
      - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
            - 10.0.0.0/8
```
