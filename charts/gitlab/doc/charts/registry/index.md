---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the Container Registry **(FREE SELF)**

The `registry` sub-chart provides the Registry component to a complete cloud-native
GitLab deployment on Kubernetes. This sub-chart makes use of the upstream
[registry](https://hub.docker.com/_/registry/) [container](https://github.com/docker/distribution-library-image)
containing [Docker Distribution](https://github.com/docker/distribution). This chart
is composed of 3 primary parts: [Service](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/service.yaml),
[Deployment](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/deployment.yaml),
and [ConfigMap](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/configmap.yaml).

All configuration is handled according to the official [Registry configuration documentation](https://docs.docker.com/registry/configuration/)
using `/etc/docker/registry/config.yml` variables provided to the `Deployment` populated
from the `ConfigMap`. The `ConfigMap` overrides the upstream defaults, but is
[based on them](https://github.com/docker/distribution-library-image/blob/master/config-example.yml).
See below for more details:

- [`distribution/cmd/registry/config-example.yml`](https://github.com/docker/distribution/blob/master/cmd/registry/config-example.yml)
- [`distribution-library-image/config-example.yml`](https://github.com/docker/distribution-library-image/blob/master/config-example.yml)

## Design Choices

A Kubernetes `Deployment` was chosen as the deployment method for this chart to allow
for simple scaling of instances, while allowing for
[rolling updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/).

This chart makes use of two required secrets and one optional:

### Required

- `global.registry.certificate.secret`: A global secret that will contain the public
  certificate bundle to verify the authentication tokens provided by the associated
  GitLab instance(s). See [documentation](https://docs.gitlab.com/ee/administration/packages/container_registry.html#use-an-external-container-registry-with-gitlab-as-an-auth-endpoint)
  on using GitLab as an auth endpoint.
- `global.registry.httpSecret.secret`: A global secret that will contain the
  [shared secret](https://docs.docker.com/registry/configuration/#http) between registry pods.

### Optional

- `profiling.stackdriver.credentials.secret`: If Stackdriver profiling is enabled and
  you need to provide explicit service account credentials, then the value in this secret
  (in the `credentials` key by default) is the GCP service account JSON credentials.
  If you are using GKE and are providing service accounts to your workloads using
  [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
  (or node service accounts, although this is not recommended), then this secret is not required
  and should not be supplied. In either case, the service account requires the role
  `roles/cloudprofiler.agent` or equivalent [manual permissions](https://cloud.google.com/profiler/docs/iam#roles)

## Configuration

We will describe all the major sections of the configuration below. When configuring
from the parent chart, these values will be:

```yaml
registry:
  enabled:
  maintenance:
    readonly:
      enabled: false
    uploadpurging:
      enabled: true
      age: 168h
      interval: 24h
      dryrun: false
  image:
    tag: 'v3.25.0-gitlab'
    pullPolicy: IfNotPresent
  annotations:
  service:
    type: ClusterIP
    name: registry
  httpSecret:
    secret:
    key:
  authEndpoint:
  tokenIssuer:
  certificate:
    secret: gitlab-registry
    key: registry-auth.crt
  deployment:
    terminationGracePeriodSeconds: 30
  draintimeout: '0'
  hpa:
    minReplicas: 2
    maxReplicas: 10
    cpu:
      targetAverageUtilization: 75
  storage:
    secret:
    key: storage
    extraKey:
  compatibility:
    schema1:
      enabled: false
  validation:
    disabled: true
    manifests:
      referencelimit: 0
      payloadsizelimit: 0
      urls:
        allow: []
        deny: []
  notifications: {}
  tolerations: []
  ingress:
    enabled: false
    tls:
      enabled: true
      secretName: redis
    annotations:
    configureCertmanager:
    proxyReadTimeout:
    proxyBodySize:
    proxyBuffering:
  networkpolicy:
    enabled: false
    egress:
      enabled: false
      rules: []
    ingress:
      enabled: false
      rules: []
```

If you chose to deploy this chart as a standalone, remove the `registry` at the top level.

## Installation parameters

| Parameter                                  | Default                                      | Description                                                                                          |
|--------------------------------------------|----------------------------------------------|------------------------------------------------------------------------------------------------------|
| `annotations`                              |                                              | Pod annotations                                                                                      |
| `podLabels`                                |                                              | Supplemental Pod labels. Will not be used for selectors.                                             |
| `common.labels`                            |                                              | Supplemental labels that are applied to all objects created by this chart.                           |
| `authAutoRedirect`                         | `true`                                       | Auth auto-redirect (must be true for Windows clients to work)                                        |
| `authEndpoint`                             | `global.hosts.gitlab.name`                   | Auth endpoint (only host and port)                                                                   |
| `certificate.secret`                       | `gitlab-registry`                            | JWT certificate                                                                                      |
| `compatiblity`                             |                                              | Configuration of compatibility settings                                                              |
| `debug`                                    |                                              | Debug port and Prometheus metrics                                                                    |
| `deployment.terminationGracePeriodSeconds` | `30`                                         | Optional duration in seconds the pod needs to terminate gracefully.                                  |
| `deployment.strategy`                      | `{}`                                         | Allows one to configure the update strategy utilized by the deployment                               |
| `draintimeout`                             | `'0'`                                        | Amount of time to wait for HTTP connections to drain after receiving a SIGTERM signal (e.g. `'10s'`) |
| `relativeurls`                             | `false`                                      | Enable the registry to return relative URLs in Location headers. |
| `enabled`                                  | `true`                                       | Enable registry flag                                                                                 |
| `hpa.cpu.targetAverageUtilization`         | `75`                                         | Target value of the average of the resource metric across all relevant pods which governs the HPA    |
| `hpa.customMetrics`                        | `[]`                                         | autoscaling/v2beta1 Metrics contains the specifications for which to use to calculate the desired replica count (overrides the default use of Average CPU Utilization configured in `targetAverageUtilization`) |
| `hpa.minReplicas`                          | `2`                                          | Minimum number of replicas                                                                           |
| `hpa.maxReplicas`                          | `10`                                         | Maximum number of replicas                                                                           |
| `httpSecret`                               |                                              | Https secret                                                                                         |
| `image.pullPolicy`                         |                                              | Pull policy for the registry image                                                                   |
| `image.pullSecrets`                        |                                              | Secrets to use for image repository                                                                  |
| `image.repository`                         | `registry`                                   | Registry image                                                                                       |
| `image.tag`                                | `v3.25.0-gitlab`                              | Version of the image to use                                                                          |
| `init.image.repository`                    |                                              | initContainer image                                                                                  |
| `init.image.tag`                           |                                              | initContainer image tag                                                                              |
| `log`                                      | `{level: info, fields: {service: registry}}` | Configure the logging options                                                                        |
| `minio.bucket`                             | `global.registry.bucket`                     | Legacy registry bucket name                                                                          |
| `maintenance.readonly.enabled`             | `false`                                      | Enable registry's read-only mode                                                                     |
| `maintenance.uploadpurging.enabled`        | `true`                                       | Enable upload purging
| `maintenance.uploadpurging.age`            | `168h`                                       | Purge uploads older than the specified age
| `maintenance.uploadpurging.interval`       | `24h`                                        | Frequency at which upload purging is performed
| `maintenance.uploadpurging.dryrun`         | `false`                                      | Only list which uploads will be purged without deleting
| `reporting.sentry.enabled`                 | `false`                                      | Enable reporting using Sentry                                                                        |
| `reporting.sentry.dsn`                     |                                              | The Sentry DSN (Data Source Name)                                                                    |
| `reporting.sentry.environment`             |                                              | The Sentry [environment](https://docs.sentry.io/product/sentry-basics/environments/)                 |
| `profiling.stackdriver.enabled`            | `false`                                      | Enable continuous profiling using Stackdriver                                                        |
| `profiling.stackdriver.credentials.secret` | `gitlab-registry-profiling-creds`            | Name of the secret containing credentials                                                                  |
| `profiling.stackdriver.credentials.key`    | `credentials`                                | Secret key in which the credentials are stored                                                             |
| `profiling.stackdriver.service`            | `RELEASE-registry` (templated Service name)| Name of the Stackdriver service to record profiles under                                             |
| `profiling.stackdriver.projectid`          | GCP project where running                    | GCP project to report profiles to                                                                    |
| `database.enabled`                         | `false`                                      | Enable metadata database. This is an experimental feature and must not be used in production environments. |
| `database.host`                            | `global.psql.host`                           | The database server hostname. |
| `database.port`                            | `global.psql.port`                           | The database server port. |
| `database.user`                            |                                              | The database username. |
| `database.password.secret`                 | `RELEASE-registry-database-password`         | Name of the secret containing the database password. |
| `database.password.key`                    | `password`                                   | Secret key in which the database password is stored. |
| `database.name`                            |                                              | The database name. |
| `database.sslmode`                         |                                              | The SSL mode. Can be one of `disable`, `allow`, `prefer`, `require`, `verify-ca` or `verify-full`. |
| `database.ssl.secret`                      | `global.psql.ssl.secret`                     | A secret containing client certificate, key and certificate authority. Defaults to the main PostgreSQL SSL secret. |
| `database.ssl.clientCertificate`           | `global.psql.ssl.clientCertificate`          | The key inside the secret referring the client certificate. |
| `database.ssl.clientKey`                   | `global.psql.ssl.clientKey`                  | The key inside the secret referring the client key.
| `database.ssl.serverCA`                    | `global.psql.ssl.serverCA`                   | The key inside the secret referring the certificate authority (CA). |
| `database.connecttimeout`                  | `0`                                          | Maximum time to wait for a connection. Zero or not specified means waiting indefinitely. |
| `database.draintimeout`                    | `0`                                          | Maximum time to wait to drain all connections on shutdown. Zero or not specified means waiting indefinitely. |
| `database.preparedstatements`              | `false`                                      | Enable prepared statements. Disabled by default for compatibility with PgBouncer. |
| `database.pool.maxidle`                    | `0`                                          | The maximum number of connections in the idle connection pool. If `maxopen` is less than `maxidle`, then `maxidle` is reduced to match the `maxopen` limit. Zero or not specified means no idle connections. |
| `database.pool.maxopen`                    | `0`                                          | The maximum number of open connections to the database. If `maxopen` is less than `maxidle`, then `maxidle` is reduced to match the `maxopen` limit. Zero or not specified means unlimited open connections. |
| `database.pool.maxlifetime`                | `0`                                          | The maximum amount of time a connection may be reused. Expired connections may be closed lazily before reuse. Zero or not specified means unlimited reuse. |
| `database.pool.maxidletime`                | `0`                                          | The maximum amount of time a connection may be idle. Expired connections may be closed lazily before reuse. Zero or not specified means unlimited duration. |
| `database.migrations.enabled`              | `true`                                       | Enable the migrations job to automatically run migrations upon initial deployment and upgrades of the Chart. Note that migrations can also be run manually from within any running Registry pods. |
| `database.migrations.activeDeadlineSeconds` | `3600`                                      | Set the [activeDeadlineSeconds](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup) on the migrations job. |
| `database.migrations.backoffLimit`         | `6`                                          | Set the [backoffLimit](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup) on the migrations job. |
| `gc.disabled`                              | `true`                                      | When set to `true`, the online GC workers are disabled. |
| `gc.maxbackoff`                            | `24h`                                        | The maximum exponential backoff duration used to sleep between worker runs when an error occurs. Also applied when there are no tasks to be processed unless `gc.noidlebackoff` is `true`. Please note that this is not the absolute maximum, as a randomized jitter factor of up to 33% is always added. |
| `gc.noidlebackoff`                         | `false`                                      | When set to `true`, disables exponential backoffs between worker runs when there are no tasks to be processed. |
| `gc.transactiontimeout`                    | `10s`                                        | The database transaction timeout for each worker run. Each worker starts a database transaction at the start. The worker run is canceled if this timeout is exceeded to avoid stalled or long-running transactions. |
| `gc.blobs.disabled`                        | `false`                                      | When set to `true`, the GC worker for blobs is disabled. |
| `gc.blobs.interval`                        | `5s`                                         | The initial sleep interval between each worker run. |
| `gc.blobs.storagetimeout`                  | `5s`                                         | The timeout for storage operations. Used to limit the duration of requests to delete dangling blobs on the storage backend. |
| `gc.manifests.disabled`                    | `false`                                      | When set to `true`, the GC worker for manifests is disabled. |
| `gc.manifests.interval`                    | `5s`                                         | The initial sleep interval between each worker run. |
| `gc.reviewafter`                           | `24h`                                        | The minimum amount of time after which the garbage collector should pick up a record for review. `-1` means no wait. |
| `migration.enabled`                | `false`                                      | When set to `true`, migration mode is enabled. New repositories will be added to the database, while existing repositories will continue to use the filesystem. This is an experimental feature and must not be used in production environments. |
| `migration.disablemirrorfs`                | `false`                                      | When set to `true`, the registry does not write metadata to the filesystem. Must be used in combination with the metadata database. This is an experimental feature and must not be used in production environments. |
| `migration.rootdirectory`                |                                              | Allows repositories that have been migrated to the database to use separate storage paths. Using a distinct root directory from the main storage driver configuration allows online migrations. This is an experimental feature and must not be used in production environments. |
| `securityContext.fsGroup`                  | `1000`                                       | Group ID under which the pod should be started                                                       |
| `securityContext.runAsUser`                | `1000`                                       | User ID under which the pod should be started                                                        |
| `serviceLabels`                            | `{}`                                         | Supplemental service labels                                                                          |
| `tokenService`                             | `container_registry`                         | JWT token service                                                                                    |
| `tokenIssuer`                              | `gitlab-issuer`                              | JWT token issuer                                                                                     |
| `tolerations`                              | `[]`                                         | Toleration labels for pod assignment                                                                 |
| `middleware.storage` |  | configuration layer for midleware storage ([s3 for instance](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#example-middleware-configuration))

## Chart configuration examples

### pullSecrets

`pullSecrets` allows you to authenticate to a private registry to pull images for a pod.

Additional details about private registries and their authentication methods can be
found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`:

```yaml
image:
  repository: my.registry.repository
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

`annotations` allows you to add annotations to the registry pods.

Below is an example use of `annotations`

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```

## Enable the sub-chart

The way we've chosen to implement compartmentalized sub-charts includes the ability
to disable the components that you may not want in a given deployment. For this reason,
the first setting you should decide on is `enabled`.

By default, Registry is enabled out of the box. Should you wish to disable it, set `enabled: false`.

## Configuring the `image`

This section details the settings for the container image used by this sub-chart's
[Deployment](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/deployment.yaml).
You can change the included version of the Registry and `pullPolicy`.

Default settings:

- `tag: 'v3.25.0-gitlab'`
- `pullPolicy: 'IfNotPresent'`

## Configuring the `service`

This section controls the name and type of the [Service](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/service.yaml).
These settings will be populated by [`values.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/values.yaml).

By default, the Service is configured as:

| Name             | Type    | Default    | Description |
|:---------------- |:-------:|:---------- |:----------- |
| `name`           | String  | `registry` | Configures the name of the service |
| `type`           | String  | `ClusterIP`| Configures the type of the service |
| `externalPort`   | Int     | `5000`     | Port exposed by the Service |
| `internalPort`   | Int     | `5000`     | Port utilized by the Pod to accept request from the service |
| `clusterIP`      | String  | `null`     | Allows one to configure a custom Cluster IP as necessary |
| `loadBalancerIP` | String  | `null`     | Allows one to configure a custom LoadBalancer IP address as necessary |

## Configuring the `ingress`

This section controls the registry Ingress.

| Name              | Type    | Default | Description |
|:----------------- |:-------:|:------- |:----------- |
| `apiVersion`      | String  |         | Value to use in the `apiVersion` field. |
| `annotations`     | String  |         | This field is an exact match to the standard `annotations` for [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/). |
| `configureCertmanager` | Boolean |    | Toggles Ingress annotation `cert-manager.io/issuer`. For more information see the [TLS requirement for GitLab Pages](../../installation/tls.md).  |
| `enabled`         | Boolean | `false` | Setting that controls whether to create Ingress objects for services that support them. When `false` the `global.ingress.enabled` setting is used. |
| `tls.enabled`     | Boolean | `true`  | When set to `false`, you disable TLS for the Registry subchart. This is mainly useful for cases in which you cannot use TLS termination at `ingress-level`, like when you have a TLS-terminating proxy before the Ingress Controller. |
| `tls.secretName`  | String  |         | The name of the Kubernetes TLS Secret that contains a valid certificate and key for the registry URL. When not set, the `global.ingress.tls.secretName` is used instead. Defaults to not being set. |

## Configuring the `networkpolicy`

This section controls the registry
[NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
This configuration is optional and is used to limit egress and Ingress of the registry to specific endpoints.
and Ingress to specific endpoints.

| Name              | Type    | Default | Description |
|:----------------- |:-------:|:------- |:----------- |
| `enabled`         | Boolean | `false` | This setting enables the `NetworkPolicy` for registry |
| `ingress.enabled` | Boolean | `false` | When set to `true`, the `Ingress` network policy will be activated. This will block all Ingress connections unless rules are specified. |
| `ingress.rules`   | Array   | `[]`    | Rules for the Ingress policy, for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |
| `egress.enabled`  | Boolean | `false` | When set to `true`, the `Egress` network policy will be activated. This will block all egress connections unless rules are specified. |
| `egress.rules`    | Array   | `[]`    | Rules for the egress policy, these for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |

### Example policy for preventing connections to all internal endpoints

The Registry service normally requires egress connections to object storage,
Ingress connections from Docker clients, and kube-dns for DNS lookups. This
adds the following network restrictions to the Registry service:

- All egress requests to the local network on `10.0.0.0/8` port 53 are allowed (for kubeDNS)
- Other egress requests to the local network on `10.0.0.0/8` are restricted
- Egress requests outside of the `10.0.0.0/8` are allowed

_Note that the registry service requires outbound connectivity to the public
internet for images on [external object storage](../../advanced/external-object-storage)_

```yaml
networkpolicy:
  enabled: true
  egress:
    enabled: true
    # The following rules enable traffic to all external
    # endpoints, except the local
    # network (except DNS requests)
    rules:
      - to:
        - ipBlock:
            cidr: 10.0.0.0/8
        ports:
        - port: 53
          protocol: UDP
      - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
            - 10.0.0.0/8
```

## Defining the Registry Configuration

The following properties of this chart pertain to the configuration of the underlying
[registry](https://hub.docker.com/_/registry/) container. Only the most critical values
for integration with GitLab are exposed. For this integration, we make use of the `auth.token.x`
settings of [Docker Distribution](https://github.com/docker/distribution), controlling
authentication to the registry via JWT [authentication tokens](https://docs.docker.com/registry/spec/auth/token/).

### httpSecret

Field `httpSecret` is a map that contains two items: `secret` and `key`.

The content of the key this references correlates to the `http.secret` value of
[registry](https://hub.docker.com/_/registry/). This value should be populated with
a cryptographically generated random string.

The `shared-secrets` job will automatically create this secret if not provided. It will be
filled with a securely generated 128 character alpha-numeric string that is base64 encoded.

To create this secret manually:

```shell
kubectl create secret generic gitlab-registry-httpsecret --from-literal=secret=strongrandomstring
```

### Notification Secret

Notification Secret is utilized for calling back to the GitLab application in various ways,
such as for Geo to help manage syncing Container Registry data between primary and secondary sites.

The `notificationSecret` secret object will be automatically created if
not provided, when the `shared-secrets` feature is enabled.

To create this secret manually:

```shell
kubectl create secret generic gitlab-registry-notification --from-literal=secret=[\"strongrandomstring\"]
```

Then proceed to set

```yaml
global:
  # To provide your own secret
  registry:
    notificationSecret:
        secret: gitlab-registry-notification
        key: secret

  # If utilising Geo, and wishing to sync the container registry
  geo:
    registry:
      replication:
        enabled: true
        primaryApiUrl: <URL to primary registry>
```

Ensuring the `secret` value is set to the name of the secret created above

### authEndpoint

The `authEndpoint` field is a string, providing the URL to the GitLab instance(s) that
the [registry](https://hub.docker.com/_/registry/) will authenticate to.

The value should include the protocol and hostname only. The chart template will automatically
append the necessary request path. The resulting value will be populated to `auth.token.realm`
inside the container. For example: `authEndpoint: "https://gitlab.example.com"`

By default this field is populated with the GitLab hostname configuration set by the
[Global Settings](../globals.md).

### certificate

The `certificate` field is a map containing two items: `secret` and `key`.

`secret` is a string containing the name of the [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/)
that houses the certificate bundle to be used to verify the tokens created by the GitLab instance(s).

`key` is the name of the `key` in the `Secret` which houses the certificate
bundle that will be provided to the [registry](https://hub.docker.com/_/registry/)
container as `auth.token.rootcertbundle`.

Default Example:

```yaml
certificate:
  secret: gitlab-registry
  key: registry-auth.crt
```

### compatibility

The `compatibility` field is a map relating directly to the configuration file's
[compatibility](https://github.com/docker/distribution/blob/master/docs/configuration.md#compatibility)
section.

Default contents:

```yaml
compatibility:
  schema1:
    enabled: false
```

### readiness and liveness probe

By default there is a readiness and liveness probe configured to
check `/debug/health` on port `5001` which is the debug port.

#### schema1

The `schema1` section controls the compatibility of the service with version 1
of the Docker manifest schema. This setting is provide as a means of supporting
Docker clients earlier than `1.10`, after which schema v2 is used by default.

If you _must_ support older versions of Docker clients, you can do so by setting
`registry.compatbility.schema1.enabled: true`.

### validation

The `validation` field is a map that controls the Docker image validation
process in the registry. When image validation is enabled the registry rejects
windows images with foreign layers, unless the `manifests.urls.allow` field
within the validation stanza is explicitly set to allow those layer urls.

Validation only happens during manifest push, so images already present in the
registry are not affected by changes to the values in this section.

The image validation is turned off by default.

To enable image validation you need to explicitly set `registry.validation.disabled: false`.

#### manifests

The `manifests` field allows configuration of validation policies particular to
manifests.

The `urls` section contains both `allow` and `deny` fields. For manifest layers
which contain URLs to pass validation, that layer must match one of the regular
expressions in the `allow` field, while not matching any regular expression in
the `deny` field.

| Name              | Type   | Default | Description                                                                                                                                                                             |
| :---------------: | :----: | :------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| `referencelimit`  | Int    | `0`     | The maximum number of references, such as layers, image configurations, and other manifests, that a single manifest may have. When set to `0` (default) this validation is disabled.    |
| `payloadsizelimit`  | Int    | `0`   | The maximum data size in bytes of manifest payloads. When set to `0` (default) this validation is disabled.    |
| `urls.allow`      | Array  | `[]`    | List of regular expressions that enables URLs in the layers of manifests. When left empty (default), layers with any URLs will be rejected.                                             |
| `urls.deny`       | Array  | `[]`    | List of regular expressions that restricts the URLs in the layers of manifests. When left empty (default), no layer with URLs which passed the `urls.allow` list will be rejected       |

### notifications

The `notifications` field is used to configure [Registry notifications](https://docs.docker.com/registry/notifications/#configuration).
It has an empty hash as default value.

| Name         | Type  | Default | Description                                                                                                          |
| :----------: | :---: | :------ | :------------------------------------------------------------------------------------------------------------------: |
| `endpoints`  | Array | `[]`    | List of items where each item correspond to an [endpoint](https://docs.docker.com/registry/configuration/#endpoints) |
| `events`     | Hash  | `{}`    | Information provided in [event](https://docs.docker.com/registry/configuration/#events) notifications                |

An example setting will look like the following:

```yaml
notifications:
  endpoints:
    - name: FooListener
      url: https://foolistener.com/event
      timeout: 500ms
      threshold: 10
      backoff: 1s
    - name: BarListener
      url: https://barlistener.com/event
      timeout: 100ms
      threshold: 3
      backoff: 1s
  events:
    includereferences: true
```

<!-- vale gitlab.Spelling = NO -->

### hpa

<!-- vale gitlab.Spelling = YES -->

The `hpa` field is an object, controlling the number of [registry](https://hub.docker.com/_/registry/)
instances to create as a part of the set. This defaults to a `minReplicas` value
of `2`, a `maxReplicas` value of 10, and configures the
`cpu.targetAverageUtilization` to 75%.

### storage

```yaml
storage:
  secret:
  key: config
  extraKey:
```

The `storage` field is a reference to a Kubernetes Secret and associated key. The content
of this secret is taken directly from [Registry Configuration: `storage`](https://docs.docker.com/registry/configuration/#storage).
Please refer to that documentation for more details.

Examples for [AWS s3](https://docs.docker.com/registry/storage-drivers/s3/) and
[Google GCS](https://docs.docker.com/registry/storage-drivers/gcs/) drivers can be
found in [`examples/objectstorage`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage):

- [`registry.s3.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.s3.yaml)
- [`registry.gcs.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.gcs.yaml)

For S3, make sure you give the correct
[permissions for registry storage](https://docs.docker.com/registry/storage-drivers/s3/#s3-permission-scopes). For more information about storage configuration, see
[Container Registry storage driver](https://docs.gitlab.com/ee/administration/packages/container_registry.html#container-registry-storage-driver) in the administration documentation.

Place the *contents* of the `storage` block into the secret, and provide the following
as items to the `storage` map:

- `secret`: name of the Kubernetes Secret housing the YAML block.
- `key`: name of the key in the secret to use. Defaults to `config`.
- `extraKey`: *(optional)* name of an extra key in the secret, which will be mounted
  to `/etc/docker/registry/storage/${extraKey}` within the container. This can be
  used to provide the `keyfile` for the `gcs` driver.

```shell
# Example using S3
kubectl create secret generic registry-storage \
    --from-file=config=registry-storage.yaml

# Example using GCS with JSON key
# - Note: `registry.storage.extraKey=gcs.json`
kubectl create secret generic registry-storage \
    --from-file=config=registry-storage.yaml \
    --from-file=gcs.json=example-project-382839-gcs-bucket.json
```

If you chose to use the `filesystem` driver:

- You will need to provide persistent volumes for this data.
- [`hpa.minReplicas`](#hpa) should be set to `1`
- [`hpa.maxReplicas`](#hpa) should be set to `1`

For the sake of resiliency and simplicity, it is recommended to make use of an
external service, such as `s3`, `gcs`, `azure` or other compatible Object Storage.

NOTE:
The chart will populate `delete.enabled: true` into this configuration
by default if not specified by the user. This keeps expected behavior in line with
the default use of MinIO, as well as the Omnibus GitLab. Any user provided value
will supersede this default.

### middleware.storage

Configuration of `middleware.storage` follows [upstream convention](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#middleware):

Configuration is fairly generic and follows similar pattern:

```yaml
middleware:
  # See https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#middleware
  storage:
    - name: cloudfront
      options:
        baseurl: https://abcdefghijklmn.cloudfront.net/
        # `privatekey` is auto-populated with the content from the privatekey Secret.
        privatekeySecret:
          secret: cloudfront-secret-name
          # "key" value is going to be used to generate file name for PEM storage:
          #   /etc/docker/registry/middleware.storage/<index>/<key>
          key: private-key-ABC.pem
        keypairid: ABCEDFGHIJKLMNOPQRST
```

Within above code `options.privatekeySecret` is a `generic` Kubernetes secret contents of which corresponds to PEM file contents:

```shell
kubectl create secret generic cloudfront-secret-name --type=kubernetes.io/ssh-auth --from-file=private-key-ABC.pem=pk-ABCEDFGHIJKLMNOPQRST.pem
```

`privatekey` used upstream is being auto-populated by chart from the privatekey Secret and will be **ignored** if specified.

#### `keypairid` variants

Various vendors use different field names for the same construct:

| Vendor | field name |
| :----: | :--------: |
| Google CDN | `keyname` |
| CloudFront | `keypairid` |

NOTE:
Only configuration of `middleware.storage` section is supported at this time.

### debug

The debug port is enabled by default and is used for the liveness/readiness
probe. Additionally, Prometheus metrics can be enabled.

```yaml
debug:
  addr:
    port: 5001
  prometheus:
    enabled: true
    path: '/metrics'
```

### health

The `health` property is optional, and contains preferences for
a periodic health check on the storage driver's backend storage.
For more details, see Docker's [configuration documentation](https://docs.docker.com/registry/configuration/#health).

```yaml
health:
  storagedriver:
    enabled: false
    interval: 10s
    threshold: 3
```

### reporting

The `reporting` property is optional and enables [reporting](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#reporting)

```yaml
reporting:
  sentry:
    enabled: true
    dsn: 'https://<key>@sentry.io/<project>'
    environment: 'production'
```

### profiling

The `profiling` property is optional and enables [continuous profiling](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#profiling)

```yaml
profiling:
  stackdriver:
    enabled: true
    credentials:
      secret: gitlab-registry-profiling-creds
      key: credentials
    service: gitlab-registry
```

### database

The `database` property is optional and enables the [metadata database](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#database).

NOTE:
The metadata database is an experimental feature and _must not_ be used in production.

NOTE:
This feature requires PostgreSQL 12 or newer.

```yaml
database:
  enabled: true
  host: registry.db.example.com
  port: 5432
  user: registry
  password:
    secret: gitlab-postgresql-password
    key: postgresql-registry-password
  dbname: registry
  sslmode: verify-full
  ssl:
    secret: gitlab-registry-postgresql-ssl
    clientKey: client-key.pem
    clientCertificate: client-cert.pem
    serverCA: server-ca.pem
  connecttimeout: 5s
  draintimeout: 2m
  preparedstatements: false
  pool:
    maxidle: 25
    maxopen: 25
    maxlifetime: 5m
    maxidletime: 5m
  migrations:
    enabled: true
    activeDeadlineSeconds: 3600
    backoffLimit: 6
```

#### Creating the database

If the Registry database is enabled, Registry will use its own database to track its state.

Follow the steps below to manually create the database and role.

NOTE:
These instructions assume you are using the bundled PostgreSQL server. If you are using your own server,
there will be some variation in how you connect.

1. Create the secret with the database password:

   ```shell
   kubectl create secret generic RELEASE_NAME-registry-database-password --from-literal=password=randomstring
   ```

1. Log into your database instance:

   ```shell
   kubectl exec -it $(kubectl get pods -l app=postgresql -o custom-columns=NAME:.metadata.name --no-headers) -- bash
   ```

   ```shell
   PGPASSWORD=$(cat $POSTGRES_POSTGRES_PASSWORD_FILE) psql -U postgres -d template1
   ```

1. Create the database user:

   ```sql
   CREATE ROLE registry WITH LOGIN;
   ```

1. Set the database user password.

   1. Fetch the password:

      ```shell
      kubectl get secret RELEASE_NAME-registry-database-password -o jsonpath="{.data.password}" | base64 --decode
      ```

   1. Set the password in the `psql` prompt:

      ```sql
      \password registry
      ```

1. Create the database:

   ```sql
   CREATE DATABASE registry WITH OWNER registry;
   ```

1. Safely exit from the PostgreSQL command line and then from the container using `exit`:

   ```shell
   template1=# exit
   ...@gitlab-postgresql-0/$ exit
   ```

### migration

The `migration` property is optional and provides options related to the
[migration](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#migration)
of metadata from the filesystem to the metadata database.

WARNING:
This is an experimental feature and _must not_ be used in production.

NOTE:
This feature requires the [metadata database](#database) to be enabled.

```yaml
migration:
  enabled: true
  disablemirrorfs: true
  rootdirectory: gitlab
```

### gc

The `gc` property is optional and provides options related to
[online garbage collection](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#gc).

WARNING:
This is an experimental feature and _must not_ be used in production.

NOTE:
This feature requires the [metadata database](#database) to be enabled.

```yaml
gc:
  disabled: false
  maxbackoff: 24h
  noidlebackoff: false
  transactiontimeout: 10s
  reviewafter: 24h
  manifests:
    disabled: false
    interval: 5s
  blobs:
    disabled: false
    interval: 5s
    storagetimeout: 5s
```

## Garbage Collection

The Docker Registry will build up extraneous data over time which can be freed using
[garbage collection](https://docs.docker.com/registry/garbage-collection/).
As of [now](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1586) there is no
fully automated or scheduled way to run the garbage collection with this Chart.

### Manual Garbage Collection

Manual garbage collection requires the registry to be in read-only mode first. Let's assume that you've already
installed the GitLab Chart using Helm, named it `mygitlab` and installed it in the namespace `gitlabns`.
Replace these values in the commands below according to your actual configuration.

```shell
# Because of https://github.com/helm/helm/issues/2948 we can't rely on --reuse-values, so let's get our current config.
helm get values mygitlab > mygitlab.yml
# Upgrade Helm installation and configure the registry to be read-only.
# The --wait parameter makes Helm wait until all ressources are in ready state, so we are safe to continue.
helm upgrade mygitlab gitlab/gitlab -f mygitlab.yml --set registry.maintenance.readOnly.enabled=true --wait
# Our registry is in r/o mode now, so let's get the name of one of the registry Pods.
# Note down the Pod name and replace the '<registry-pod>' placeholder below with that value.
# Replace the single quotes to double quotes (' => ") if you are using this with Windows' cmd.exe.
kubectl get pods -n gitlabns -l app=registry -o jsonpath='{.items[0].metadata.name}'
# Run the actual garbage collection. Check the registry's manual if you really want the '-m' parameter.
kubectl exec -n gitlabns <registry-pod> -- /bin/registry garbage-collect -m /etc/docker/registry/config.yml
# Reset registry back to original state.
helm upgrade mygitlab gitlab/gitlab -f mygitlab.yml --wait
# All done :)
```

### Running administrative commands against the Container Registry

The administrative commands can be run against the Container Registry
only from a Registry pod, where both the `registry` binary as well as necessary
configuration is available. [Issue #2629](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2629)
is open to discuss how to provide this functionality from the toolbox pod.

To run administrative commands:

1. Connect to a Registry pod:

   ```shell
   kubectl exec -it <registry-pod> -- bash
   ```

1. Once inside the Registry pod, the `registry` binary is available in `PATH` and
   can be used directly. The configuration file is available at
   `/etc/docker/registry/config.yml`. The following example checks the status
   of the database migration:

   ```shell
   registry database migrate status /etc/docker/registry/config.yml
   ```

For further details and other available commands, refer to the relevant
documentation:

- [General Registry documentation](https://docs.docker.com/registry/)
- [GitLab-specific Registry documentation](https://gitlab.com/gitlab-org/container-registry/-/tree/master/docs-gitlab)
