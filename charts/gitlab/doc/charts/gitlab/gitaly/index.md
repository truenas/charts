---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the GitLab-Gitaly chart **(FREE SELF)**

The `gitaly` sub-chart provides a configurable deployment of Gitaly Servers.

## Requirements

This chart depends on access to the Workhorse service, either as part of the
complete GitLab chart or provided as an external service reachable from the Kubernetes
cluster this chart is deployed onto.

## Design Choices

The Gitaly container used in this chart also contains the GitLab Shell codebase in
order to perform the actions on the Git repositories that have not yet been ported into Gitaly.
The Gitaly container includes a copy of the GitLab Shell container within it, and
as a result we also need to configure GitLab Shell within this chart.

## Configuration

The `gitaly` chart is configured in two parts: [external services](#external-services),
and [chart settings](#chart-settings).

Gitaly is by default deployed as a component when deploying the GitLab
chart. If deploying Gitaly separately, `global.gitaly.enabled` needs to
be set to `false` and additional configuration will need to be performed
as described in the [external Gitaly documentation](../../../advanced/external-gitaly/).

### Installation command line options

The table below contains all the possible charts configurations that can be supplied to
the `helm install` command using the `--set` flags.

| Parameter                       | Default                                    | Description                                                                                                                                                          |
| ------------------------------  | ------------------------------------------ | ----------------------------------------                                                                                                                             |
| `annotations`                   |                                            | Pod annotations                                                                                                                                                      |
| `common.labels`                 | `{}`                                       | Supplemental labels that are applied to all objects created by this chart.                                                                                           |
| `podLabels`                     |                                            | Supplemental Pod labels. Will not be used for selectors.                                                                                                             |
| `external[].hostname`           | `- ""`                                     | hostname of external node                                                                                                                                            |
| `external[].name`               | `- ""`                                     | name of external node storage                                                                                                                                        |
| `external[].port`               | `- ""`                                     | port of external node                                                                                                                                                |
| `extraContainers`               |                                            | List of extra containers to include                                                                                                                                  |
| `extraInitContainers`           |                                            | List of extra init containers to include                                                                                                                             |
| `extraVolumeMounts`             |                                            | List of extra volumes mounts to do                                                                                                                                  |
| `extraVolumes`                  |                                            | List of extra volumes to create                                                                                                                                      |
| `extraEnv`                      |                                            | List of extra environment variables to expose                                                                                                                        |
| `gitaly.serviceName`            |                                            | The name of the generated Gitaly service. Overrides `global.gitaly.serviceName`, and defaults to `<RELEASE-NAME>-gitaly`                                             |
| `image.pullPolicy`              | `Always`                                   | Gitaly image pull policy                                                                                                                                             |
| `image.pullSecrets`             |                                            | Secrets for the image repository                                                                                                                                     |
| `image.repository`              | `registry.com/gitlab-org/build/cng/gitaly` | Gitaly image repository                                                                                                                                              |
| `image.tag`                     | `master`                                   | Gitaly image tag                                                                                                                                                     |
| `init.image.repository`         |                                            | initContainer image                                                                                                                                                  |
| `init.image.tag`                |                                            | initContainer image tag                                                                                                                                              |
| `internal.names[]`              | `- default`                                | Ordered names of StatefulSet storages                                                                                                                                 |
| `serviceLabels`                 | `{}`                                       | Supplemental service labels                                                                                                                                          |
| `service.externalPort`          | `8075`                                     | Gitaly service exposed port                                                                                                                                          |
| `service.internalPort`          | `8075`                                     | Gitaly internal port                                                                                                                                                 |
| `service.name`                  | `gitaly`                                   | The name of the Service port that Gitaly is behind in the Service object.                                                                                            |
| `service.type`                  | `ClusterIP`                                | Gitaly service type                                                                                                                                                  |
| `securityContext.fsGroup`       | `1000`                                     | Group ID under which the pod should be started                                                                                                                       |
| `securityContext.runAsUser`     | `1000`                                     | User ID under which the pod should be started                                                                                                                        |
| `tolerations`                   | `[]`                                       | Toleration labels for pod assignment                                                                                                                                 |
| `persistence.accessMode`        | `ReadWriteOnce`                            | Gitaly persistence access mode                                                                                                                                       |
| `persistence.annotations`       |                                            | Gitaly persistence annotations                                                                                                                                       |
| `persistence.enabled`           | `true`                                     | Gitaly enable persistence flag                                                                                                                                       |
| `persistence.matchExpressions`  |                                            | Label-expression matches to bind                                                                                                                                     |
| `persistence.matchLabels`       |                                            | Label-value matches to bind                                                                                                                                          |
| `persistence.size`              | `50Gi`                                     | Gitaly persistence volume size                                                                                                                                       |
| `persistence.storageClass`      |                                            | storageClassName for provisioning                                                                                                                                    |
| `persistence.subPath`           |                                            | Gitaly persistence volume mount path                                                                                                                                 |
| `priorityClassName`             |                                            | Gitaly StatefulSet priorityClassName                                                                                                                                 |
| `logging.level`                 |                                            | Log level                                                                                                                                                            |
| `logging.format`                | `json`                                     | Log format                                                                                                                                                           |
| `logging.sentryDsn`             |                                            | Sentry DSN URL - Exceptions from Go server                                                                                                                           |
| `logging.rubySentryDsn`         |                                            | Sentry DSN URL - Exceptions from `gitaly-ruby`                                                                                                                       |
| `logging.sentryEnvironment`     |                                            | Sentry environment to be used for logging                                                                                                                            |
| `ruby.maxRss`                   |                                            | Gitaly-Ruby resident set size (RSS) that triggers a memory restart (bytes)                                                                                           |
| `ruby.gracefulRestartTimeout`   |                                            | Graceful period before a force restart after exceeding Max RSS                                                                                                       |
| `ruby.restartDelay`             |                                            | Time that Gitaly-Ruby memory must remain high before a restart (seconds)                                                                                             |
| `ruby.numWorkers`               |                                            | Number of Gitaly-Ruby worker processes                                                                                                                               |
| `shell.concurrency[]`           |                                            | Concurrency of each RPC endpoint Specified using keys `rpc` and `maxPerRepo`                                                                                         |
| `git.catFileCacheSize`          |                                            | Cache size used by Git cat-file process                                                                                                                              |
| `prometheus.grpcLatencyBuckets` |                                            | Buckets corresponding to histogram latencies on GRPC method calls to be recorded by Gitaly. A string form of the array (for example, `"[1.0, 1.5, 2.0]"`) is required as input |
| `statefulset.strategy`          | `{}`                                       | Allows one to configure the update strategy utilized by the statefulset                                                                                              |

## Chart configuration examples

### extraEnv

`extraEnv` allows you to expose additional environment variables in all containers in the pods.

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

### image.pullSecrets

`pullSecrets` allows you to authenticate to a private registry to pull images for a pod.

Additional details about private registries and their authentication methods can be
found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`

```yaml
image:
  repository: my.gitaly.repository
  tag: latest
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

`annotations` allows you to add annotations to the Gitaly pods.

Below is an example use of `annotations`:

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```

### priorityClassName

`priorityClassName` allows you to assign a [PriorityClass](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/)
to the Gitaly pods.

Below is an example use of `priorityClassName`:

```yaml
priorityClassName: persistence-enabled
```

### Altering security contexts

Gitaly `StatefulSet` performance may suffer when repositories have large
amounts of files due to a [known issue with `fsGroup` in upstream Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods).
Mitigate the issue by changing or fully deleting the settings for the
`securityContext`.

```yaml
gitlab:
  gitaly:
    securityContext:
      fsGroup: ""
      runAsUser: ""
```

NOTE:
The example syntax eliminates the `securityContext` setting entirely.
Setting `securityContext: {}` or `securityContext:` does not work due
to the way Helm merges default values with user provided configuration.

## External Services

This chart should be attached the Workhorse service.

### Workhorse

```yaml
workhorse:
  host: workhorse.example.com
  serviceName: webservice
  port: 8181
```

| Name          | Type    | Default   | Description |
|:------------- |:-------:|:--------- |:----------- |
| `host`        | String  |           | The hostname of the Workhorse server. This can be omitted in lieu of `serviceName`. |
| `port`        | Integer | `8181`    | The port on which to connect to the Workhorse server.|
| `serviceName` | String  | `webservice` | The name of the `service` which is operating the Workhorse server. If this is present, and `host` is not, the chart will template the hostname of the service (and current `.Release.Name`) in place of the `host` value. This is convenient when using Workhorse as a part of the overall GitLab chart. |

## Chart Settings

The following values are used to configure the Gitaly Pods.

NOTE:
Gitaly uses an Auth Token to authenticate with the Workhorse and Sidekiq
services. The Auth Token secret and key are sourced from the `global.gitaly.authToken`
value. Additionally, the Gitaly container has a copy of GitLab Shell, which has some configuration
that can be set. The Shell authToken is sourced from the `global.shell.authToken`
values.

### Git Repository Persistence

This chart provisions a PersistentVolumeClaim and mounts a corresponding persistent
volume for the Git repository data. You'll need physical storage available in the
Kubernetes cluster for this to work. If you'd rather use emptyDir, disable PersistentVolumeClaim
with: `persistence.enabled: false`.

NOTE:
The persistence settings for Gitaly are used in a volumeClaimTemplate
that should be valid for all your Gitaly pods. You should *not* include settings
that are meant to reference a single specific volume (such as `volumeName`). If you want
to reference a specific volume, you need to manually create the PersistentVolumeClaim.

NOTE:
You can't change these through our settings once you've deployed. In [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
the `VolumeClaimTemplate` is immutable.

```yaml
persistence:
  enabled: true
  storageClass: standard
  accessMode: ReadWriteOnce
  size: 50Gi
  matchLabels: {}
  matchExpressions: []
  subPath: "/data"
  annotations: {}
```

| Name               | Type    | Default         | Description |
|:------------------ |:-------:|:--------------- |:----------- |
| `accessMode`       | String  | `ReadWriteOnce` | Sets the accessMode requested in the PersistentVolumeClaim. See [Kubernetes Access Modes Documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for details. |
| `enabled`          | Boolean | `true`          | Sets whether or not to use a PersistentVolumeClaims for the repository data. If `false`, an emptyDir volume is used. |
| `matchExpressions` | Array   |                 | Accepts an array of label condition objects to match against when choosing a volume to bind. This is used in the `PersistentVolumeClaim` `selector` section. See the [volumes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector). |
| `matchLabels`      | Map     |                 | Accepts a Map of label names and label values to match against when choosing a volume to bind. This is used in the `PersistentVolumeClaim` `selector` section. See the [volumes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector). |
| `size`             | String  | `50Gi`          | The minimum volume size to request for the data persistence. |
| `storageClass`     | String  |                 | Sets the storageClassName on the Volume Claim for dynamic provisioning. When unset or null, the default provisioner will be used. If set to a hyphen, dynamic provisioning is disabled. |
| `subPath`          | String  |                 | Sets the path within the volume to mount, rather than the volume root. The root is used if the subPath is empty. |
| `annotations`      | Map     |                 | Sets the annotations on the Volume Claim for dynamic provisioning. See [Kubernetes Annotations Documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) for details. |

### Running Gitaly over TLS

NOTE:
This section refers to Gitaly being run inside the cluster using
the Helm charts. If you are using an external Gitaly instance and want to use
TLS for communicating with it, refer [the external Gitaly documentation](../../../advanced/external-gitaly/index.md#connecting-to-external-gitaly-over-tls)

Gitaly supports communicating with other components over TLS. This is controlled
by the settings `global.gitaly.tls.enabled` and `global.gitaly.tls.secretName`.
Follow the steps to run Gitaly over TLS:

1. The Helm chart expects a certificate to be provided for communicating over
   TLS with Gitaly. This certificate should apply to all the Gitaly nodes that
   are present. Hence all hostnames of each of these Gitaly nodes should be
   added as a Subject Alternate Name (SAN) to the certificate.

   To know the hostnames to use, check the file `/srv/gitlab/config/gitlab.yml`
   file in the Toolbox pod and check the various
   `gitaly_address` fields specified under `repositories.storages` key within it.

   ```shell
   kubectl exec -it <Toolbox pod> -- grep gitaly_address /srv/gitlab/config/gitlab.yml
   ```

NOTE:
A basic script for generating custom signed certificates for
internal Gitaly pods [can be found in this repository](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/generate_certificates.sh).
Users can use or refer that script to generate certificates with proper
SAN attributes.

1. Create a k8s TLS secret using the certificate created.

   ```shell
   kubectl create secret tls gitaly-server-tls --cert=gitaly.crt --key=gitaly.key
   ```

1. Redeploy the Helm chart by passing the additional arguments `--set global.gitaly.tls.enabled=true --set global.gitaly.tls.secretName=<secret name>`

### Global server hooks

The Gitaly StatefulSet has support for [Global server hooks](https://docs.gitlab.com/ee/administration/server_hooks.html#create-a-global-server-hook-for-all-repositories). The hook scripts run on the Gitaly pod, and are therefore limited to the tools available in the [Gitaly container](https://gitlab.com/gitlab-org/build/CNG/-/blob/master/gitaly/Dockerfile).

The hooks are populated using [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/), and can be used by setting the following values as appropriate:

1. `global.gitaly.hooks.preReceive.configmap`
1. `global.gitaly.hooks.postReceive.configmap`
1. `global.gitaly.hooks.update.configmap`

To populate the ConfigMap, you can point `kubectl` to a directory of scripts:

```shell
kubectl create configmap MAP_NAME --from-file /PATH/TO/SCRIPT/DIR
```
