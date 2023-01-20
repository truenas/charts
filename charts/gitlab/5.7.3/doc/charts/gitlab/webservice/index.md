---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the GitLab Webservice Chart **(FREE SELF)**

The `webservice` sub-chart provides the GitLab Rails webserver with two Webservice workers
per pod. (The minimum necessary for a single pod to be able to serve any web request in GitLab)

Currently the container used in the chart also includes a copy of GitLab Workhorse,
which we haven't split out yet.

## Requirements

This chart depends on Redis, PostgreSQL, Gitaly, and Registry services, either as
part of the complete GitLab chart or provided as external services reachable from
the Kubernetes cluster this chart is deployed onto.

## Configuration

The `webservice` chart is configured as follows: [Global Settings](#global-settings),
[Deployments settings](#deployments-settings), [Ingress Settings](#ingress-settings), [External Services](#external-services), and
[Chart Settings](#chart-settings).

## Installation command line options

The table below contains all the possible chart configurations that can be supplied
to the `helm install` command using the `--set` flags.

| Parameter                        | Default               | Description                                    |
| -------------------------------- | --------------------- | ---------------------------------------------- |
| `annotations`                    |                       | Pod annotations                                |
| `podLabels`                      |                       | Supplemental Pod labels. Will not be used for selectors. |
| `common.labels`                  |                       | Supplemental labels that are applied to all objects created by this chart. |
| `deployment.terminationGracePeriodSeconds`      | 30     | Seconds that Kubernetes will wait for a pod to exit, note this must be longer than `shutdown.blackoutSeconds` |
| `deployment.livenessProbe.initialDelaySeconds`  | 20     | Delay before liveness probe is initiated       |
| `deployment.livenessProbe.periodSeconds`        | 60     | How often to perform the liveness probe        |
| `deployment.livenessProbe.timeoutSeconds`       | 30     | When the liveness probe times out              |
| `deployment.livenessProbe.successThreshold`     | 1      | Minimum consecutive successes for the liveness probe to be considered successful after having failed |
| `deployment.livenessProbe.failureThreshold`     | 3      | Minimum consecutive failures for the liveness probe to be considered failed after having succeeded |
| `deployment.readinessProbe.initialDelaySeconds` | 0      | Delay before readiness probe is initiated      |
| `deployment.readinessProbe.periodSeconds`       | 10     | How often to perform the readiness probe       |
| `deployment.readinessProbe.timeoutSeconds`      | 2      | When the readiness probe times out             |
| `deployment.readinessProbe.successThreshold`    | 1      | Minimum consecutive successes for the readiness probe to be considered successful after having failed |
| `deployment.readinessProbe.failureThreshold`    | 3      | Minimum consecutive failures for the readiness probe to be considered failed after having succeeded |
| `deployment.strategy`      | `{}`                  | Allows one to configure the update strategy used by the deployment. When not provided, the cluster default is used. |
| `enabled`                        | `true`                | Webservice enabled flag                           |
| `extraContainers`                |                       | List of extra containers to include            |
| `extraInitContainers`            |                       | List of extra init containers to include       |
| `extras.google_analytics_id`     | `nil`                 | Google Analytics ID for frontend               |
| `extraVolumeMounts`              |                       | List of extra volumes mounts to do            |
| `extraVolumes`                   |                       | List of extra volumes to create                |
| `extraEnv`                       |                       | List of extra environment variables to expose  |
| `gitlab.webservice.workhorse.image` | `registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ee` | Workhorse image repository |
| `gitlab.webservice.workhorse.tag`   |                       | Workhorse image tag                            |
| `hpa.targetAverageValue`         | `1`                   | Set the autoscaling target value               |
| `sshHostKeys.mount`         | `false`                   | Whether to mount the GitLab Shell secret containing the public SSH keys.                |
| `sshHostKeys.mountName`         | `ssh-host-keys`                   | Name of the mounted volume.                |
| `sshHostKeys.types`         | `[dsa,rsa,ecdsa,ed25519]`                   | List of SSH key types to mount.               |
| `image.pullPolicy`               | `Always`              | Webservice image pull policy                      |
| `image.pullSecrets`              |                       | Secrets for the image repository               |
| `image.repository`               | `registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ee` | Webservice image repository |
| `image.tag`                      |                       | Webservice image tag                              |
| `init.image.repository`          |                       | initContainer image                            |
| `init.image.tag`                 |                       | initContainer image tag                        |
| `metrics.enabled`                | `true`                | Toggle Prometheus metrics exporter             |
| `minio.bucket`                   | `git-lfs`             | Name of storage bucket, when using MinIO       |
| `minio.port`                     | `9000`                | Port for MinIO service                         |
| `minio.serviceName`              | `minio-svc`           | Name of MinIO service                          |
| `monitoring.ipWhitelist`         | `[0.0.0.0/0]`         | List of IPs to whitelist for the monitoring endpoints |
| `monitoring.exporter.enabled`         | `false`          | Enable webserver to expose Prometheus metrics  |
| `monitoring.exporter.port`            | `8083`           | Port number to use for the metrics exporter    |
| `psql.password.key`              | `psql-password`       | Key to psql password in psql secret            |
| `psql.password.secret`           | `gitlab-postgres`     | psql secret name                               |
| `psql.port`                      |                       | Set PostgreSQL server port. Takes precedence over `global.psql.port` |
| `puma.disableWorkerKiller`       | `false`               | Disables Puma worker memory killer |
| `puma.workerMaxMemory`           | `1024`                | The maximum memory (in megabytes) for the Puma worker killer |
| `puma.threads.min`               | `4`                   | The minimum amount of Puma threads |
| `puma.threads.max`               | `4`                   | The maximum amount of Puma threads |
| `rack_attack.git_basic_auth`     | `{}`                  | See [GitLab documentation](https://docs.gitlab.com/ee/security/rack_attack.html) for details |
| `redis.serviceName`              | `redis`               | Redis service name                             |
| `registry.api.port`              | `5000`                | Registry port                                  |
| `registry.api.protocol`          | `http`                | Registry protocol                              |
| `registry.api.serviceName`       | `registry`            | Registry service name                          |
| `registry.enabled`               | `true`                | Add/Remove registry link in all projects menu  |
| `registry.tokenIssuer`           | `gitlab-issuer`       | Registry token issuer                          |
| `replicaCount`                   | `1`                   | Webservice number of replicas                     |
| `resources.requests.cpu`         | `300m`                | Webservice minimum CPU                            |
| `resources.requests.memory`      | `1.5G`                | Webservice minimum memory                         |
| `service.externalPort`           | `8080`                | Webservice exposed port                           |
| `securityContext.fsGroup`        | `1000`                | Group ID under which the pod should be started |
| `securityContext.runAsUser`      | `1000`                | User ID under which the pod should be started  |
| `serviceLabels`                  | `{}`                  | Supplemental service labels |
| `service.internalPort`           | `8080`                | Webservice internal port                          |
| `service.type`                   | `ClusterIP`           | Webservice service type                           |
| `service.workhorseExternalPort`  | `8181`                | Workhorse exposed port                         |
| `service.workhorseInternalPort`  | `8181`                | Workhorse internal port                        |
| `service.loadBalancerIP`         |                       | IP address to assign to LoadBalancer (if supported by cloud provider) |
| `service.loadBalancerSourceRanges` |                     | List of IP CIDRs allowed access to LoadBalancer (if supported) Required for service.type = LoadBalancer |
| `shell.authToken.key`            | `secret`              | Key to shell token in shell secret             |
| `shell.authToken.secret`         | `gitlab-shell-secret` | Shell token secret                             |
| `shell.port`                     | `nil`                 | Port number to use in SSH URLs generated by UI |
| `shutdown.blackoutSeconds`       | `10`                  | Number of seconds to keep Webservice running after receiving shutdown, note this must shorter than `deployment.terminationGracePeriodSeconds` |
| `tolerations`                    | `[]`                  | Toleration labels for pod assignment           |
| `trusted_proxies`                | `[]`                  | See [GitLab documentation](https://docs.gitlab.com/ee/install/installation.html#adding-your-trusted-proxies) for details |
| `workhorse.logFormat`            | `json`                | Logging format. Valid formats: `json`, `structured`, `text` |
| `workerProcesses`                | `2`                   | Webservice number of workers                      |
| `workhorse.keywatcher`           | `true`                | Subscribe workhorse to Redis. This is **required** by any deployment servicing request to `/api/*`, but can be safely disabled for other deployments |
| `workhorse.shutdownTimeout`                    | `global.webservice.workerTimeout + 1` (seconds) | Time to wait for all Web requests to clear from Workhorse. Examples: `1min`, `65s`. |
| `workhorse.trustedCIDRsForPropagation`         |         | A list of CIDR blocks that can be trusted for propagating a correlation ID. The `-propagateCorrelationID` option must also be used in `workhorse.extraArgs` for this to work. See the [Workhorse documentation](https://gitlab.com/gitlab-org/gitlab/-/blob/master/workhorse/doc/operations/configuration.md) for more details. |
| `workhorse.trustedCIDRsForXForwardedFor`       |         | A list of CIDR blocks that can be used to resolve the actual client IP via the `X-Forwarded-For` HTTP header. This is used with `workhorse.trustedCIDRsForPropagation`. See the [Workhorse documentation](https://gitlab.com/gitlab-org/gitlab/-/blob/master/workhorse/doc/operations/configuration.md) for more details. |
| `workhorse.livenessProbe.initialDelaySeconds`  | 20      | Delay before liveness probe is initiated       |
| `workhorse.livenessProbe.periodSeconds`        | 60      | How often to perform the liveness probe        |
| `workhorse.livenessProbe.timeoutSeconds`       | 30      | When the liveness probe times out              |
| `workhorse.livenessProbe.successThreshold`     | 1       | Minimum consecutive successes for the liveness probe to be considered successful after having failed |
| `workhorse.livenessProbe.failureThreshold`     | 3       | Minimum consecutive failures for the liveness probe to be considered failed after having succeeded |
| `workhorse.monitoring.exporter.enabled`        | `false` | Enable workhorse to expose Prometheus metrics  |
| `workhorse.monitoring.exporter.port`           | 9229  | Port number to use for workhorse Prometheus metrics |
| `workhorse.readinessProbe.initialDelaySeconds` | 0       | Delay before readiness probe is initiated      |
| `workhorse.readinessProbe.periodSeconds`       | 10      | How often to perform the readiness probe       |
| `workhorse.readinessProbe.timeoutSeconds`      | 2       | When the readiness probe times out             |
| `workhorse.readinessProbe.successThreshold`    | 1       | Minimum consecutive successes for the readiness probe to be considered successful after having failed |
| `workhorse.readinessProbe.failureThreshold`    | 3       | Minimum consecutive failures for the readiness probe to be considered failed after having succeeded |
| `workhorse.imageScaler.maxProcs`               | 2       | The maximum number of image scaling processes that may run concurrently |
| `workhorse.imageScaler.maxFileSizeBytes`       | 250000  | The maximum file size in bytes for images to be processed by the scaler |
| `webServer` | `puma` | Selects web server (Webservice/Puma) that would be used for request handling |
| `priorityClassName`                            | `""`    | Allow configuring pods `priorityClassName`, this is used to control pod priority in case of eviction |

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
found in [the Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`:

```yaml
image:
  repository: my.webservice.repository
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

`annotations` allows you to add annotations to the Webservice pods. For example:

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```

### strategy

`deployment.strategy` allows you to change the deployment update strategy. It defines how the pods will be recreated when deployment is updated. When not provided, the cluster default is used.
For example, if you don't want to create extra pods when the rolling update starts and change max unavailable pods to 50%:

```yaml
deployment:
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 50%
```

You can also change the type of update strategy to `Recreate`, but be careful as it will kill all pods before scheduling new ones, and the web UI will be unavailable until the new pods are started. In this case, you don't need to define `rollingUpdate`, only `type`:

```yaml
deployment:
  strategy:
    type: Recreate
```

For more details, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy).

## Using the Community Edition of this chart

By default, the Helm charts use the Enterprise Edition of GitLab. If desired, you
can use the Community Edition instead. Learn more about the
[differences between the two](https://about.gitlab.com/install/ce-or-ee/).

In order to use the Community Edition, set `image.repository` to
`registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ce` and `workhorse.image`
to `registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ce`.

## Global Settings

We share some common global settings among our charts. See the [Globals Documentation](../../globals.md)
for common configuration options, such as GitLab and Registry hostnames.

## Deployments settings

This chart has the ability to create multiple Deployment objects and their related
resources. This feature allows requests to the GitLab application to be distributed between multiple sets of Pods using path based routing.

The keys of this Map (`default` in this example) are the "name" for each. `default`
will have a Deployment, Service, HorizontalPodAutoscaler, PodDisruptionBudget, and
optional Ingress created with `RELEASE-webservice-default`.

Any property not provided will inherit from the `gitlab-webservice` chart defaults.

```yaml
deployments:
  default:
    ingress:
      path: # Does not inherit or default. Leave blank to disable Ingress.
      pathType: Prefix
      provider: nginx
      annotations:
        # inherits `ingress.anntoations`
      proxyConnectTimeout: # inherits `ingress.proxyConnectTimeout`
      proxyReadTimeout:    # inherits `ingress.proxyReadTimeout`
      proxyBodySize:       # inherits `ingress.proxyBodySize`
    deployment:
      annotations: # map
      labels: # map
      # inherits `deployment`
    pod:
      labels: # additional labels to .podLabels
      annotations: # map
        # inherit from .Values.annotations
    service:
      labels: # additional labels to .serviceLabels
      annotations: # additional annotations to .service.annotations
        # inherits `service.annotations`
    hpa:
      minReplicas: # defaults to .minReplicas
      maxReplicas: # defaults to .maxReplicas
      metrics: # optional replacement of HPA metrics definition
      # inherits `hpa`
    pdb:
      maxUnavailable: # inherits `maxUnavailable`
    resources: # `resources` for `webservice` container
      # inherits `resources`
    workhorse: # map
      # inherits `workhorse`
    extraEnv: #
      # inherits `extraEnv`
    puma: # map
      # inherits `puma`
    workerProcesses: # inherits `workerProcesses`
    shutdown:
      # inherits `shutdown`
    nodeSelector: # map
      # inherits `nodeSelector`
    tolerations: # array
      # inherits `tolerations`
```

### Deployments Ingress

Each `deployments` entry will inherit from chart-wide [Ingress settings](#ingress-settings). Any value presented here will override those provided there. Outside of `path`, all settings are identical to those.

```yaml
webservice:
  deployments:
    default:
      ingress:
        path: /
   api:
     ingress:
       path: /api
```

The `path` property is directly populated into the Ingress's `path` property, and allows one to control URI paths which are directed to each service. In the example above,
`default` acts as the catch-all path, and `api` received all traffic under `/api`

You can disable a given Deployment from having an associated Ingress resource created by setting `path` to empty. See below, where `internal-api` will never receive external traffic.

```yaml
webservice:
  deployments:
    default:
      ingress:
        path: /
   api:
     ingress:
       path: /api
   internal-api:
     ingress:
       path:
```

## Ingress Settings

| Name                                   | Type    | Default | Description |
|:-------------------------------------- |:-------:|:------- |:----------- |
| `ingress.apiVersion`                   | String  |         | Value to use in the `apiVersion` field. |
| `ingress.annotations` | Map  |  See [below](#annotations) | These annotations will be used for every Ingress. For example: `ingress.annotations."nginx\.ingress\.kubernetes\.io/enable-access-log"=true`. |
| `ingress.configureCertmanager`         | Boolean |         | Toggles Ingress annotation `cert-manager.io/issuer`. For more information see the [TLS requirement for GitLab Pages](../../../installation/tls.md).  |
| `ingress.enabled`                      | Boolean | `false` | Setting that controls whether to create Ingress objects for services that support them. When `false`, the `global.ingress.enabled` setting value is used. |
| `ingress.proxyBodySize`                | String  | `512m`  | [See Below](#proxybodysize). |
| `ingress.tls.enabled`                  | Boolean | `true`  | When set to `false`, you disable TLS for GitLab Webservice. This is mainly useful for cases in which you cannot use TLS termination at Ingress-level, like when you have a TLS-terminating proxy before the Ingress Controller. |
| `ingress.tls.secretName`               | String  | (empty) | The name of the Kubernetes TLS Secret that contains a valid certificate and key for the GitLab URL. When not set, the `global.ingress.tls.secretName` value is used instead. |
| `ingress.tls.smardcardSecretName`      | String  | (empty) | The name of the Kubernetes TLS SEcret that contains a valid certificate and key for the GitLab smartcard URL if enabled. When not set, the `global.ingress.tls.secretName` value is used instead. |

### annotations

`annotations` is used to set annotations on the Webservice Ingress.

We set one annotation by default: `nginx.ingress.kubernetes.io/service-upstream: "true"`.
This helps balance traffic to the Webservice pods more evenly by telling NGINX to directly
contact the Service itself as the upstream. For more information, see the
[NGINX docs](https://github.com/kubernetes/ingress-nginx/blob/nginx-0.21.0/docs/user-guide/nginx-configuration/annotations.md#service-upstream).

To override this, set:

```yaml
gitlab:
  webservice:
    ingress:
      annotations:
        nginx.ingress.kubernetes.io/service-upstream: "false"
```

### proxyBodySize

`proxyBodySize` is used to set the NGINX proxy maximum body size. This is commonly
required to allow a larger Docker image than the default.
It is equivalent to the `nginx['client_max_body_size']` configuration in an
[Omnibus installation](https://docs.gitlab.com/omnibus/settings/nginx.html#request-entity-too-large).
As an alternative option,
you can set the body size with either of the following two parameters too:

- `gitlab.webservice.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-body-size"`
- `global.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-body-size"`

## Resources

### Memory requests/limits

Each pod spawns an amount of workers equal to `workerProcesses`, who each use
some baseline amount of memory. We recommend:

- A minimum of 1.25GB per worker (`requests.memory`)
- A maximum of 1.5GB per worker (`limits.memory`)

Note that required resources are dependent on the workload generated by users
and may change in the future based on changes or upgrades in the GitLab application.

Default:

```yaml
workerProcesses: 2
resources:
  requests:
    memory: 2.5G # = 2 * 1.25G
# limits:
#   memory: 3G   # = 2 * 1.5G
```

With 4 workers configured:

```yaml
workerProcesses: 4
resources:
  requests:
    memory: 5G   # = 4 * 1.25G
# limits:
#   memory: 6G   # = 4 * 1.5G
```

## External Services

### Redis

The Redis documentation has been consolidated in the [globals](../../globals.md#configure-redis-settings)
page. Please consult this page for the latest Redis configuration options.

### PostgreSQL

The PostgreSQL documentation has been consolidated in the [globals](../../globals.md#configure-postgresql-settings)
page. Please consult this page for the latest PostgreSQL configuration options.

### Gitaly

Gitaly is configured by [global settings](../../globals.md). Please see the
[Gitaly configuration documentation](../../globals.md#configure-gitaly-settings).

### MinIO

```yaml
minio:
  serviceName: 'minio-svc'
  port: 9000
```

| Name          | Type    | Default     | Description |
|:------------- |:-------:|:----------- |:----------- |
| `port`        | Integer | `9000`      | Port number to reach the MinIO `Service` on. |
| `serviceName` | String  | `minio-svc` | Name of the `Service` that is exposed by the MinIO pod. |

### Registry

```yaml
registry:
  host: registry.example.com
  port: 443
  api:
    protocol: http
    host: registry.example.com
    serviceName: registry
    port: 5000
  tokenIssuer: gitlab-issuer
  certificate:
    secret: gitlab-registry
    key: registry-auth.key
```

| Name                 | Type    | Default         | Description |
|:-------------------- |:-------:|:--------------- |:----------- |
| `api.host`           | String  |                 | The hostname of the Registry server to use. This can be omitted in lieu of `api.serviceName`. |
| `api.port`           | Integer | `5000`          | The port on which to connect to the Registry API. |
| `api.protocol`       | String  |                 | The protocol Webservice should use to reach the Registry API. |
| `api.serviceName`    | String  | `registry`      | The name of the `service` which is operating the Registry server. If this is present, and `api.host` is not, the chart will template the hostname of the service (and current `.Release.Name`) in place of the `api.host` value. This is convenient when using Registry as a part of the overall GitLab chart. |
| `certificate.key`    | String  |                 | The name of the `key` in the `Secret` which houses the certificate bundle that will be provided to the [registry](https://hub.docker.com/_/registry/) container as `auth.token.rootcertbundle`. |
| `certificate.secret` | String  |                 | The name of the [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/) that houses the certificate bundle to be used to verify the tokens created by the GitLab instance(s). |
| `host`               | String  |                 | The external hostname to use for providing Docker commands to users in the GitLab UI. Falls back to the value set in the `registry.hostname` template. Which determines the registry hostname based on the values set in `global.hosts`. See the [Globals Documentation](../../globals.md) for more information. |
| `port`               | Integer |                 | The external port used in the hostname. Using port `80` or `443` will result in the URLs being formed with `http`/`https`. Other ports will all use `http` and append the port to the end of hostname, for example `http://registry.example.com:8443`. |
| `tokenIssuer`        | String  | `gitlab-issuer` | The name of the auth token issuer. This must match the name used in the Registry's configuration, as it incorporated into the token when it is sent. The default of `gitlab-issuer` is the same default we use in the Registry chart. |

## Chart Settings

The following values are used to configure the Webservice Pods.

| Name              | Type    | Default | Description |
|:----------------- |:-------:|:------- |:----------- |
| `replicaCount`    | Integer | `1`     | The number of Webservice instances to create in the deployment. |
| `workerProcesses` | Integer | `2`     | The number of Webservice workers to run per pod. You must have at least `2` workers available in your cluster in order for GitLab to function properly. Note that increasing the `workerProcesses` will increase the memory required by approximately `400MB` per worker, so you should update the pod `resources` accordingly. |

### metrics.enabled

By default, each pod exposes a metrics endpoint at `/-/metrics`. Metrics are only
available when [GitLab Prometheus metrics](https://docs.gitlab.com/ee/administration/monitoring/prometheus/gitlab_metrics.html)
are enabled in the Admin area. When metrics are enabled, annotations are added to
each pod allowing a Prometheus server to discover and scrape the exposed metrics.

### GitLab Shell

GitLab Shell uses an Auth Token in its communication with Webservice. Share the token
with GitLab Shell and Webservice using a shared Secret.

```yaml
shell:
  authToken:
    secret: gitlab-shell-secret
    key: secret
  port:
```

| Name               | Type    | Default | Description |
|:------------------ |:-------:|:------- |:----------- |
| `authToken.key`    | String  |         | Defines the name of the key in the secret (below) that contains the authToken. |
| `authToken.secret` | String  |         | Defines the name of the Kubernetes `Secret` to pull from. |
| `port`             | Integer | `22`    | The port number to use in the generation of SSH URLs within the GitLab UI. Controlled by `global.shell.port`. |

### WebServer options

Current version of chart supports Puma web server.

Puma unique options:

| Name               | Type    | Default | Description |
|:------------------ |:-------:|:------- |:----------- |
| `puma.workerMaxMemory`           | Integer | `1024`                | The maximum memory (in megabytes) for the Puma worker killer |
| `puma.threads.min`               | Integer | `4`                   | The minimum amount of Puma threads |
| `puma.threads.max`               | Integer | `4`                   | The maximum amount of Puma threads |

## Configuring the `networkpolicy`

This section controls the
[NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
This configuration is optional and is used to limit Egress and Ingress of the
Pods to specific endpoints.

| Name              | Type    | Default | Description |
|:----------------- |:-------:|:------- |:----------- |
| `enabled`         | Boolean | `false` | This setting enables the `NetworkPolicy` |
| `ingress.enabled` | Boolean | `false` | When set to `true`, the `Ingress` network policy will be activated. This will block all Ingress connections unless rules are specified. |
| `ingress.rules`   | Array   | `[]`    | Rules for the Ingress policy, for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |
| `egress.enabled`  | Boolean | `false` | When set to `true`, the `Egress` network policy will be activated. This will block all egress connections unless rules are specified. |
| `egress.rules`    | Array   | `[]`    | Rules for the egress policy, these for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |

### Example Network Policy

The webservice service requires Ingress connections for only the Prometheus
exporter if enabled and traffic coming from the NGINX Ingress, and normally
requires Egress connections to various places. This examples adds the following
network policy:

- All Ingress requests from the network on TCP `10.0.0.0/8` port 8080 are allowed for metrics exporting and NGINX Ingress
- All Egress requests to the network on UDP `10.0.0.0/8` port 53 are allowed for DNS
- All Egress requests to the network on TCP `10.0.0.0/8` port 5432 are allowed for PostgreSQL
- All Egress requests to the network on TCP `10.0.0.0/8` port 6379 are allowed for Redis
- All Egress requests to the network on TCP `10.0.0.0/8` port 8075 are allowed for Gitaly
- Other Egress requests to the local network on `10.0.0.0/8` are restricted
- Egress requests outside of the `10.0.0.0/8` are allowed

_Note the example provided is only an example and may not be complete_

_Note that the Webservice requires outbound connectivity to the public internet
for images on [external object storage](../../../advanced/external-object-storage)_

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
        - port: 8080
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
            cidr: 10.0.0.0/8
        ports:
        - port: 8075
          protocol: TCP
      - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
            - 10.0.0.0/8
```

### LoadBalancer Service

If the `service.type` is set to `LoadBalancer`, you can optionally specify `service.loadBalancerIP` to create
the `LoadBalancer` with a user-specified IP (if your cloud provider supports it).

When the `service.type` is set to `LoadBalancer` you must also set `service.loadBalancerSourceRanges` to restrict
the CIDR ranges that can access the `LoadBalancer` (if your cloud provider supports it).
This is currently required due to an issue where [metric ports are exposed](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2500).

Additional information about the `LoadBalancer` service type can be found in
[the Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/#loadbalancer)

```yaml
service:
  type: LoadBalancer
  loadBalancerIP: 1.2.3.4
  loadBalancerSourceRanges:
  - 10.0.0.0/8
```
