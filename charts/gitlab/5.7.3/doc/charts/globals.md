---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Configure Charts using Globals **(FREE SELF)**

To reduce configuration duplication when installing our wrapper Helm chart, several
configuration settings are available to be set in the `global` section of `values.yaml`.
These global settings are used across several charts, while all other settings are scoped
within their chart. See the [Helm documentation on globals](https://helm.sh/docs/chart_template_guide/subcharts_and_globals/#global-chart-values)
for more information on how the global variables work.

- [Hosts](#configure-host-settings)
- [Ingress](#configure-ingress-settings)
- [GitLab Version](#gitlab-version)
- [PostgreSQL](#configure-postgresql-settings)
- [Redis](#configure-redis-settings)
- [Grafana](#configure-grafana-integration)
- [Registry](#configure-registry-settings)
- [Gitaly](#configure-gitaly-settings)
- [Praefect](#configure-praefect-settings)
- [MinIO](#configure-minio-settings)
- [appConfig](#configure-appconfig-settings)
- [Rails](#configure-rails-settings)
- [Workhorse](#configure-workhorse-settings)
- [GitLab Shell](#configure-gitlab-shell)
- [Pages](#configure-gitlab-pages)
- [Webservice](#configure-webservice)
- [Custom Certificate Authorities](#custom-certificate-authorities)
- [Application Resource](#application-resource)
- [Busybox image](#busybox-image)
- [Service Accounts](#service-accounts)
- [Annotations](#annotations)
- [Tracing](#tracing)
- [extraEnv](#extraenv)
- [OAuth](#configure-oauth-settings)
- [Outgoing email](#outgoing-email)
- [Platform](#platform)
- [Affinity](#affinity)

## Configure Host settings

The GitLab global host settings are located under the `global.hosts` key.

```yaml
global:
  hosts:
    domain: example.com
    hostSuffix: staging
    https: false
    externalIP:
    gitlab:
      name: gitlab.example.com
      https: false
    registry:
      name: registry.example.com
      https: false
    minio:
      name: minio.example.com
      https: false
    smartcard:
      name: smartcard.example.com
    kas:
      name: kas.example.com
    pages:
      name: pages.example.com
      https: false
```

| Name                   | Type    | Default       | Description |
|:---------------------- |:-------:|:------------- |:----------- |
| `domain`               | String  | `example.com` | The base domain. GitLab and Registry will be exposed on the subdomain of this setting. This defaults to `example.com`, but is not used for hosts that have their `name` property configured. See the `gitlab.name`, `minio.name`, and `registry.name` sections below. |
| `externalIP`           |         | `nil`         | Set the external IP address that will be claimed from the provider. This will be templated into the [NGINX chart](nginx/index.md#configuring-nginx), in place of the more complex `nginx.service.loadBalancerIP`. |
| `https`                | Boolean | `true`        | If set to true, you will need to ensure the NGINX chart has access to the certificates. In cases where you have TLS-termination in front of your Ingresses, you probably want to look at [`global.ingress.tls.enabled`](#configure-ingress-settings). Set to false for external URLs to use `http://` instead of `https`. |
| `hostSuffix`           | String  |               | [See Below](#hostsuffix). |
| `gitlab.https`         | Boolean | `false`       | If `hosts.https` or `gitlab.https` are `true`, the GitLab external URL will use `https://` instead of `http://`. |
| `gitlab.name`          | String  |               | The hostname for GitLab. If set, this hostname is used, regardless of the `global.hosts.domain` and `global.hosts.hostSuffix` settings. |
| `gitlab.hostnameOverride`             | String  |                | Override the hostname used in Ingress configuration of the Webservice. Useful if GitLab has to be reachable behind a WAF that rewrites the Hostname to an internal hostname (e.g.: `gitlab.example.com` --> `gitlab.cluster.local`). |
| `gitlab.serviceName`   | String  | `webservice`     | The name of the `service` which is operating the GitLab server. The chart will template the hostname of the service (and current `.Release.Name`) to create the proper internal serviceName. |
| `gitlab.servicePort`   | String  | `workhorse`   | The named port of the `service` where the GitLab server can be reached. |
| `minio.https`          | Boolean | `false`       | If `hosts.https` or `minio.https` are `true`, the MinIO external URL will use `https://` instead of `http://`. |
| `minio.name`           | String  | `minio`       | The hostname for MinIO. If set, this hostname is used, regardless of the `global.hosts.domain` and `global.hosts.hostSuffix` settings. |
| `minio.serviceName`    | String  | `minio`       | The name of the `service` which is operating the MinIO server. The chart will template the hostname of the service (and current `.Release.Name`) to create the proper internal serviceName. |
| `minio.servicePort`    | String  | `minio`       | The named port of the `service` where the MinIO server can be reached. |
| `registry.https`       | Boolean | `false`       | If `hosts.https` or `registry.https` are `true`, the Registry external URL will use `https://` instead of `http://`. |
| `registry.name`        | String  | `registry`    | The hostname for Registry. If set, this hostname is used, regardless of the `global.hosts.domain` and `global.hosts.hostSuffix` settings. |
| `registry.serviceName` | String  | `registry`    | The name of the `service` which is operating the Registry server. The chart will template the hostname of the service (and current `.Release.Name`) to create the proper internal serviceName. |
| `registry.servicePort` | String  | `registry`    | The named port of the `service` where the Registry server can be reached. |
| `smartcard.name`       | String  | `smartcard`   | The hostname for smartcard authentication. If set, this hostname is used, regardless of the `global.hosts.domain` and `global.hosts.hostSuffix` settings. |
| `kas.name`             | String  | `kas`         | The hostname for the KAS. If set, this hostname is used, regardless of the `global.hosts.domain` and `global.hosts.hostSuffix` settings. |
| `kas.https`            | Boolean | `false`       | If `hosts.https` or `kas.https` are `true`, the KAS external URL will use `wss://` instead of `ws://`. |
| `pages.name`           | String  | `pages`       | The hostname for GitLab Pages. If set, this hostname is used, regardless of the `global.hosts.domain` and `global.hosts.hostSuffix` settings. |
| `pages.https`          | String  |               | If `global.pages.https` or `global.hosts.pages.https` or `global.hosts.https` are `true`, then URL for GitLab Pages in the Project settings UI will use `https://` instead of `http://`. |

### hostSuffix

The `hostSuffix` is appended to the subdomain when assembling a hostname using the
base `domain`, but is not used for hosts that have their own `name` set.

Defaults to being unset. If set, the suffix is appended to the subdomain with a hyphen.
The example below would result in using external hostnames like `gitlab-staging.example.com`
and `registry-staging.example.com`:

```yaml
global:
  hosts:
    domain: example.com
    hostSuffix: staging
```

## Configure Ingress settings

The GitLab global host settings for Ingress are located under the `global.ingress` key:

| Name                           | Type    | Default        | Description |
|:------------------------------ |:-------:|:-------        |:----------- |
| `apiVersion`                   | String  |                | API version to use in the Ingress object definitions.
| `annotations.*annotation-key*` | String  |                | Where `annotation-key` is a string that will be used with the value as an annotation on every Ingress. For Example: `global.ingress.annotations."nginx\.ingress\.kubernetes\.io/enable-access-log"=true`. No global annotations are provided by default. |
| `configureCertmanager`         | Boolean | `true`         | [See below](#globalingressconfigurecertmanager). |
| `class`                        | String  | `gitlab-nginx` | Global setting that controls `kubernetes.io/ingress.class` annotation in `Ingress` resources. |
| `enabled`                      | Boolean | `true`         | Global setting that controls whether to create Ingress objects for services that support them. |
| `tls.enabled`                  | Boolean | `true`         | When set to `false`, this disables TLS in GitLab. This is useful for cases in which you cannot use TLS termination of Ingresses, such as when you have a TLS-terminating proxy before the Ingress Controller. If you want to disable https completely, this should be set to `false` together with [`global.hosts.https`](#configure-host-settings). |
| `tls.secretName`               | String  |                | The name of the [Kubernetes TLS Secret](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) that contains a **wildcard** certificate and key for the domain used in `global.hosts.domain`. |
| `path`                         | String  | `/`            | Default for `path` entries in [Ingress objects](https://kubernetes.io/docs/concepts/services-networking/ingress/) |
| `pathType`                     | String  | `Prefix`       | A [Path Type](https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types) allows you to specify how a path should be matched. Our current default is `Prefix` but you can use `ImplementationSpecific` or `Exact` depending on your use case. |
| `provider`                     | String  | `nginx`       | Global setting that defines the Ingress provider to use. `nginx` is used as the default provider.  |

### Ingress Path

This chart employs `global.ingress.path` as a means to assist those users that need to alter the definition of `path` entries for their Ingress objects.
Many users have no need for this setting, and _should not configure it_.

For those users who need to have their `path` definitions end in `/*` to match their load balancer / proxy behaviors, such as when using `ingress.class: gce` in GCP,
`ingress.class: alb` in AWS, or another such provider.

This setting ensures that all `path` entries in Ingress resources throughout this chart are rendered with this.
The only exception is when populating the [`gitlab/webservice` deployments settings](gitlab/webservice/index.md#deployments-settings), where `path` must be specified.

### Cloud provider LoadBalancers

Various cloud providers' LoadBalancer implementations have an impact on configuration of the Ingress resources and NGINX controller deployed as part of this chart. The next table provides examples.

| Provider | Layer | Example snippet |
| :-- | --: | :-- |
| AWS | 4 | [aws/elb-layer4-loadbalancer](https://gitlab.com/gitlab-org/charts/gitlab/-/tree/master/examples/aws/elb-layer4-loadbalancer.yaml) |
| AWS | 7 | [aws/elb-layer7-loadbalancer](https://gitlab.com/gitlab-org/charts/gitlab/-/tree/master/examples/aws/elb-layer7-loadbalancer.yaml) |

### `global.ingress.configureCertmanager`

Global setting that controls the automatic configuration of [cert-manager](https://artifacthub.io/packages/helm/jetstack/cert-manager)
for Ingress objects. If `true`, relies on `certmanager-issuer.email` being set.

If `false` and `global.ingress.tls.secretName` is not set, this will activate automatic
self-signed certificate generation, which creates a **wildcard** certificate for all
Ingress objects.

If you wish to use an external `cert-manager`, you must provide the following:

- `gitlab.webservice.ingress.tls.secretName`
- `registry.ingress.tls.secretName`
- `minio.ingress.tls.secretName`
- `global.ingress.annotations`

## GitLab Version

NOTE:
This value should only used for development purposes, or by explicit request of GitLab support. Please avoid using this value
on production environments and set the version as described
in [Deploy using Helm](../installation/deployment.md#deploy-using-helm)

The GitLab version used in the default image tag for the charts can be changed using
the `global.gitlabVersion` key:

```shell
--set global.gitlabVersion=11.0.1
```

This impacts the default image tag used in the `webservice`, `sidekiq`, and `migration`
charts. Note that the `gitaly`, `gitlab-shell` and `gitlab-runner` image tags should
be separately updated to versions compatible with the GitLab version.

## Configure PostgreSQL settings

The GitLab global PostgreSQL settings are located under the `global.psql` key.

```yaml
global:
  psql:
    host: psql.example.com
    # serviceName: pgbouncer
    port: 5432
    database: gitlabhq_production
    username: gitlab
    applicationName:
    preparedStatements: false
    connectTimeout:
    keepalives:
    keepalivesIdle:
    keepalivesInterval:
    keepalivesCount:
    tcpUserTimeout:
    password:
      useSecret: true
      secret: gitlab-postgres
      key: psql-password
      file:
```

| Name                 | Type      | Default                | Description                                                                                                                                                                                    |
| :-----------------   | :-------: | :--------------------- | :-----------                                                                                                                                                                                   |
| `host`               | String    |                        | The hostname of the PostgreSQL server with the database to use. This can be omitted if using PostgreSQL deployed by this chart.                                                                |
| `serviceName`        | String    |                        | The name of the `service` which is operating the PostgreSQL database. If this is present, and `host` is not, the chart will template the hostname of the service in place of the `host` value. |
| `database`           | String    | `gitlabhq_production`  | The name of the database to use on the PostgreSQL server.                                                                                                                                      |
| `password.useSecret` | Boolean      | `true`                 | Controls whether the password for PostgreSQL is read from a secret or file.                                                                                                                    |
| `password.file`      | String    |                        | Defines the path to the file that contains the password for PostgreSQL. Ignored if `password.useSecret` is true                                                                                |
| `password.key`       | String    |                        | The `password.key` attribute for PostgreSQL defines the name of the key in the secret (below) that contains the password. Ignored if `password.useSecret` is false.                            |
| `password.secret`    | String    |                        | The `password.secret` attribute for PostgreSQL defines the name of the Kubernetes `Secret` to pull from. Ignored if `password.useSecret` is false.                                             |
| `port`               | Integer   | `5432`                 | The port on which to connect to the PostgreSQL server.                                                                                                                                         |
| `username`           | String    | `gitlab`               | The username with which to authenticate to the database.                                                                                                                                       |
| `preparedStatements` | Boolean      | `false`                | If prepared statements should be used when communicating with the PostgreSQL server.                                                                                                           |
| `connectTimeout`     | Integer   |                        | The number of seconds to wait for a database connection.                                                                                                                                       |
| `keepalives`         | Integer   |                        | Controls whether client-side TCP keepalives are used (1, meaning on, 0, meaning off).                                                                                                          |
| `keepalivesIdle`     | Integer   |                        | The number of seconds of inactivity after which TCP should send a keepalive message to the server. A value of zero uses the system default.                                                    |
| `keepalivesInterval` | Integer   |                        | The number of seconds after which a TCP keepalive message that is not acknowledged by the server should be retransmitted. A value of zero uses the system default.                             |
| `keepalivesCount`    | Integer   |                        | The number of TCP keepalives that can be lost before the client's connection to the server is considered dead. A value of zero uses the system default.                                        |
| `tcpUserTimeout`     | Integer   |                        | The number of milliseconds that transmitted data may remain unacknowledged before a connection is forcibly closed. A value of zero uses the system default.                                    |
| `applicationName`    | String    |                        | The name of the application connecting to the database. Set to a blank string (`""`) to disable. By default, this will be set to the name of the running process (e.g. `sidekiq`, `puma`).     |

### PostgreSQL per chart

In some complex deployments, it may be desired to configure different parts of
this chart with different configurations for PostgreSQL. As of `v4.2.0`, all
properties available within `global.psql` can be set on a per-chart basis,
for example `gitlab.sidekiq.psql`. The local settings will override global values
when supplied, inheriting any _not present_ from `global.psql`, with the exception
of `psql.load_balancing`.

[PostgreSQL load balancing](#postgresql-load-balancing) will _never_ inherit
from the global, by design.

### PostgreSQL SSL

NOTE:
SSL support is mutual TLS only.
See [issue #2034](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2034)
and [issue #1817](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1817).

If you want to connect GitLab with a PostgreSQL database over mutual TLS, create a secret
containing the client key, client certificate and server certificate authority as different
secret keys. Then describe the secret's structure using the `global.psql.ssl` mapping.

```yaml
global:
  psql:
    ssl:
      secret: db-example-ssl-secrets # Name of the secret
      clientCertificate: cert.pem    # Secret key storing the certificate
      clientKey: key.pem             # Secret key of the certificate's key
      serverCA: server-ca.pem        # Secret key containing the CA for the database server
```

| Name                | Type    | Default | Description |
|:-----------------   |:-------:|:------- |:----------- |
| `secret`            | String  |         | Name of the Kubernetes `Secret` containing the following keys |
| `clientCertificate` | String  |         | Name of the key within the `Secret` containing the client certificate. |
| `clientKey`         | String  |         | Name of the key within the `Secret` containing the client certificate's key file. |
| `serverCA`          | String  |         | Name of the key within the `Secret` containing the certificate authority for the server. |

You may also need to set ```extraEnv``` values to export environment values to point to the correct keys.

```yaml
global:
  extraEnv:
      PGSSLCERT: '/etc/gitlab/postgres/ssl/client-certificate.pem'
      PGSSLKEY: '/etc/gitlab/postgres/ssl/client-key.pem'
      PGSSLROOTCERT: '/etc/gitlab/postgres/ssl/server-ca.pem'
```

### PostgreSQL load balancing

This feature requires the use of an
[external PostgreSQL](../advanced/external-db/), as this chart does not
deploy PostgreSQL in an HA fashion.

The Rails components in GitLab have the ability to [make use of PostgreSQL
clusters to load balance read-only queries](https://docs.gitlab.com/ee/administration/database_load_balancing.html).

This feature can be configured in two fashions:

- Using a static lists of _hostnames_ for the secondaries.
- Using a DNS based service discovery mechanism.

Configuration with a static list of is straight forward:

```yaml
global:
  psql:
    host: primary.database
    load_balancing:
       hosts:
       - secondary-1.database
       - secondary-2.database
```

Configuration of service discovery can be more complex. For a complete
details of this configuration, the parameters and their associated
behaviors, see [Service Discovery](https://docs.gitlab.com/ee/administration/database_load_balancing.html#service-discovery)
in the [GitLab Administration documentation](https://docs.gitlab.com/ee/administration/index.html).

```yaml
global:
  psql:
    host: primary.database
    load_balancing:
      discover:
        record:  secondary.postgresql.service.consul
        # record_type: A
        # nameserver: localhost
        # port: 8600
        # interval: 60
        # disconnect_timeout: 120
        # use_tcp: false
```

Further tuning is also available, in regards to the
[handling of stale reads](https://docs.gitlab.com/ee/administration/database_load_balancing.html#handling-stale-reads).
The GitLab Administration documentation covers these items in detail,
and those properties can be added directly under `load_balancing`.

```yaml
global:
  psql:
    load_balancing:
      max_replication_difference: # See documentation
      max_replication_lag_time:   # See documentation
      replica_check_interval:     # See documentation
```

## Configure Redis settings

The GitLab global Redis settings are located under the `global.redis` key.

By default we use an single, non-replicated Redis instance. If desired, a
highly available Redis can be deployed instead. To install an HA Redis
cluster one needs to set `redis.cluster.enabled=true` when the GitLab
chart is installed.

You can bring an external Redis instance by setting `redis.install=false`, and
following our [advanced documentation](../advanced/external-redis/index.md) for
configuration.

```yaml
global:
  redis:
    host: redis.example.com
    serviceName: redis
    port: 6379
    password:
      enabled: true
      secret: gitlab-redis
      key: redis-password
    scheme:
```

| Name               | Type    | Default | Description |
|:------------------ |:-------:|:------- |:----------- |
| `host`             | String  |         | The hostname of the Redis server with the database to use. This can be omitted in lieu of `serviceName`. |
| `serviceName`      | String  | `redis` | The name of the `service` which is operating the Redis database. If this is present, and `host` is not, the chart will template the hostname of the service (and current `.Release.Name`) in place of the `host` value. This is convenient when using Redis as a part of the overall GitLab chart. |
| `port`             | Integer | `6379`  | The port on which to connect to the Redis server. |
| `password.enabled` | Boolean    | true    | The `password.enabled` provides a toggle for using a password with the Redis instance. |
| `password.key`     | String  |         | The `password.key` attribute for Redis defines the name of the key in the secret (below) that contains the password. |
| `password.secret`  | String  |         | The `password.secret` attribute for Redis defines the name of the Kubernetes `Secret` to pull from. |
| `scheme`           | String  | `redis` | The URI scheme to be used to generate Redis URLs. Valid values are `redis`, `rediss`, and `tcp`. If using `rediss` (SSL encrypted connection) scheme, the certificate used by the server should be a part of the system's trusted chains. This can be done by adding them to the [custom certificate authorities](#custom-certificate-authorities) list. |

### Configure Redis chart-specific settings

Settings to configure the [Redis chart](https://github.com/bitnami/charts/tree/master/bitnami/redis)
directly are located under the `redis` key:

```yaml
redis:
  install: true
  image:
    registry: registry.example.com
    repository: example/redis
    tag: x.y.z
```

Refer to the [full list of settings](https://artifacthub.io/packages/helm/bitnami/redis/11.3.4#parameters)
for more information.

### Redis Sentinel support

The current Redis Sentinel support only supports Sentinels that have
been deployed separately from the GitLab chart. As a result, the Redis
deployment through the GitLab chart should be disabled with `redis.install=false`.
The Kubernetes Secret containing the Redis password will need to be manually created
before deploying the GitLab chart.

The installation of an HA Redis cluster from the GitLab chart does not
support using sentinels. If sentinel support is desired, a Redis cluster
needs to be created separately from the GitLab chart install. This can be
done inside or outside the Kubernetes cluster.

An issue to track the [supporting of sentinels in a GitLab deployed
Redis cluster](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1810) has
been created for tracking purposes.

```yaml
redis:
  install: false
global:
  redis:
    host: redis.example.com
    serviceName: redis
    port: 6379
    sentinels:
      - host: sentinel1.example.com
        port: 26379
      - host: sentinel2.exeample.com
        port: 26379
    password:
      enabled: true
      secret: gitlab-redis
      key: redis-password
```

| Name               | Type    | Default | Description |
|:------------------ |:-------:|:------- |:----------- |
| `host`             | String  |         | The `host` attribute needs to be set to the cluster name as specified in the `sentinel.conf`.|
| `sentinels.[].host`| String  |         | The hostname of Redis Sentinel server for a Redis HA setup. |
| `sentinels.[].port`| Integer | `26379` | The port on which to connect to the Redis Sentinel server. |

All the prior Redis attributes in the general [configure Redis settings](#configure-redis-settings)
continue to apply with the Sentinel support unless re-specified in the table above.

### Multiple Redis support

The GitLab chart includes support for running with separate Redis instances
for different persistence classes, currently:

| Instance       | Purpose                                                         |
|:---------------|:----------------------------------------------------------------|
| `cache`        | Store cached data                                               |
| `queues`       | Store Sidekiq background jobs                                   |
| `sharedState`  | Store various persistent data such as distributed locks         |
| `actioncable`  | Pub/Sub queue backend for ActionCable                           |
| `traceChunks`  | Store job traces temporarily                                    |
| `rateLimiting` | Store rate-limiting usage for RackAttack and Application Limits |
| `sessions`     | Store user session data                                         |

Any number of the instances may be specified. Any instances not specified
will be handled by the primary Redis instance specified
by `global.redis.host` or use the deployed Redis instance from the chart.
For example:

```yaml
redis:
  install: false
global:
  redis:
    host: redis.example
    port: 6379
    password:
      enabled: true
      secret: redis-secret
      key: redis-password
    cache:
      host: cache.redis.example
      port: 6379
      password:
        enabled: true
        secret: cache-secret
        key: cache-password
    sharedState:
      host: shared.redis.example
      port: 6379
      password:
        enabled: true
        secret: shared-secret
        key: shared-password
    queues:
      host: queues.redis.example
      port: 6379
      password:
        enabled: true
        secret: queues-secret
        key: queues-password
    actioncable:
      host: cable.redis.example
      port: 6379
      password:
        enabled: true
        secret: cable-secret
        key: cable-password
    traceChunks:
      host: traceChunks.redis.example
      port: 6379
      password:
        enabled: true
        secret: traceChunks-secret
        key: traceChunks-password
    rateLimiting:
      host: rateLimiting.redis.example
      port: 6379
      password:
        enabled: true
        secret: rateLimiting-secret
        key: rateLimiting-password
    sessions:
      host: sessions.redis.example
      port: 6379
      password:
        enabled: true
        secret: sessions-secret
        key: sessions-password
```

The following table describes the attributes for each dictionary of the
Redis instances.

| Name               | Type    | Default | Description |
|:------------------ |:-------:|:------- |:----------- |
| `.host`            | String  |         | The hostname of the Redis server with the database to use. |
| `.port`            | Integer | `6379`  | The port on which to connect to the Redis server. |
| `.password.enabled`| Boolean    | true    | The `password.enabled` provides a toggle for using a password with the Redis instance. |
| `.password.key`    | String  |         | The `password.key` attribute for Redis defines the name of the key in the secret (below) that contains the password. |
| `.password.secret` | String  |         | The `password.secret` attribute for Redis defines the name of the Kubernetes `Secret` to pull from. |

The primary Redis definition is required as there are additional persistence
classes that have not been separated.

Each instance definition may also use Redis Sentinel support. Sentinel
configurations **are not shared** and needs to be specified for each
instance that uses Sentinels. Please refer to the [Sentinel configuration](#redis-sentinel-support)
for the attributes that are used to configure Sentinel servers.

### Specifying secure Redis scheme (SSL)

In order to connect to Redis using SSL, the `rediss` (note the double `s`) scheme parameter is required:

```yaml
global:
  redis:
    scheme: rediss
  --set global.redis.scheme=rediss
```

### Password-less Redis Servers

Some Redis services such as Google Cloud Memorystore do not make use of passwords and the associated `AUTH` command. The use and requirement for a password can be disabled via the following configuration setting:

```yaml
global:
  redis:
    password:
      enabled: false
    host: ${REDIS_PRIVATE_IP}
redis:
  enabled: false
```

## Configure Grafana integration

The GitLab global Grafana settings are located under `global.grafana`. At this time, the only setting available is `global.grafana.enabled`.

When set to `true`, the GitLab chart will deploy the [`grafana/grafana` chart](https://artifacthub.io/packages/helm/grafana/grafana), expose it under `/-/grafana` of the GitLab Ingress, and pre-configure it with a secure random password. The generated password can be found in the Secret named `gitlab-grafana-initial-root-password`.

The GitLab chart connects to the deployed Prometheus instance.

## Configure Registry settings

The global Registry settings are located under the `global.registry` key.

```yaml
global:
  registry:
    bucket: registry
    certificate:
    httpSecret:
    notificationSecret:
    notifications: {}
```

For more details on `bucket`, `certificate`, `httpSecret`, and `notificationSecret` settings, see the documentation within the [registry chart](registry/index.md).

### notifications

This setting is used to configure
[Registry notifications](https://docs.docker.com/registry/configuration/#notifications).
It takes in a map (following upstream specification), but with an added feature
of providing sensitive headers as Kubernetes secrets. For example, consider the
following snippet where the Authorization header contains sensitive data while
other headers contain regular data:

```yaml
global:
  registry:
    notifications:
      events:
        includereferences: true
      endpoints:
        - name: CustomListener
          url: https://mycustomlistener.com
          timeout: 500mx
          threshold: 5
          backoff: 1s
          headers:
            X-Random-Config: [plain direct]
            Authorization:
              secret: registry-authorization-header
              key: password
```

In this example, the header `X-Random-Config` is a regular header and its value
can be provided in plaintext in the `values.yaml` file or via `--set` flag.
However, the header `Authorization` is a sensitive one, so mounting it from a
Kubernetes secret is preferred. For details regarding the structure of the
secret, refer the [secrets documentation](../installation/secrets.md#registry-sensitive-notification-headers)

## Configure Gitaly settings

The global Gitaly settings are located under the `global.gitaly` key.

```yaml
global:
  gitaly:
    internal:
      names:
        - default
        - default2
    external:
      - name: node1
        hostname: node1.example.com
        port: 8075
    authToken:
      secret: gitaly-secret
      key: token
    tls:
      enabled: true
      secretName: gitlab-gitaly-tls
```

### Gitaly hosts

[Gitaly](https://gitlab.com/gitlab-org/gitaly) is a service that provides high-level
RPC access to Git repositories, which handles all Git calls made by GitLab.

Administrators can chose to use Gitaly nodes in the following ways:

- [Internal to the chart](#internal), as part of a `StatefulSet` via the [Gitaly chart](gitlab/gitaly/).
- [External to the chart](#external), as external pets.
- [Mixed environment](#mixed) using both internal and external nodes.

See [Repository Storage Paths](https://docs.gitlab.com/ee/administration/repository_storage_paths.html)
documentation for details on managing which nodes will be used for new projects.

If `gitaly.host` is provided, `gitaly.internal` and `gitaly.external` properties will *be ignored*.
See the [deprecated Gitaly settings](#deprecated-gitaly-settings).

The Gitaly authentication token is expected to be identical for
all Gitaly services at this time, internal or external. Ensure these are aligned.
See [issue #1992](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1992) for further details.

#### Internal

The `internal` key currently consists of only one key, `names`, which is a list of
[storage names](https://docs.gitlab.com/ee/administration/repository_storage_paths.html)
to be managed by the chart. For each listed name, *in logical order*, one pod will
be spawned, named `${releaseName}-gitaly-${ordinal}`, where `ordinal` is the index
within the `names` list. If dynamic provisioning is enabled, the `PersistentVolumeClaim`
will match.

This list defaults to `['default']`, which provides for 1 pod related to one
[storage path](https://docs.gitlab.com/ee/administration/repository_storage_paths.html).

Manual scaling of this item is required, by adding or removing entries in
`gitaly.internal.names`. When scaling down, any repository that has not been moved
to another node will become unavailable. Since the Gitaly chart is a `StatefulSet`,
dynamically provisioned disks *will not* be reclaimed. This means the data disks
will persist, and the data on them can be accessed when the set is scaled up again
by re-adding a node to the `names` list.

A sample [configuration of multiple internal nodes](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/gitaly/values-multiple-internal.yaml)
can be found in the examples folder.

#### External

The `external` key provides a configuration for Gitaly nodes external to the cluster.
Each item of this list has 3 keys:

- `name`: The name of the [storage](https://docs.gitlab.com/ee/administration/repository_storage_paths.html).
  An entry with `name: default` is required.
- `hostname`: The host of Gitaly services.
- `port`: (optional) The port number to reach the host on. Defaults to `8075`.
- `tlsEnabled`: (optional) Override `global.gitaly.tls.enabled` for this particular entry.

We provide an [advanced configuration](../advanced/index.md) guide for
[using an external Gitaly service](../advanced/external-gitaly/index.md). You can also
find sample [configuration of multiple external services](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/gitaly/values-multiple-external.yaml)
in the examples folder.

You may use an external [Praefect](https://docs.gitlab.com/ee/administration/gitaly/praefect.html)
to provide highly available Gitaly services. Configuration of the two is
interchangeable, as from the viewpoint of the clients, there is no difference.

#### Mixed

It is possible to use both internal and external Gitaly nodes, but be aware that:

- There must always be a node named `default`, which Internal provides by default.
- External nodes will be populated first, then Internal.

A sample [configuration of mixed internal and external nodes](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/gitaly/values-multiple-mixed.yaml)
can be found in the examples folder.

### authToken

The `authToken` attribute for Gitaly has two sub keys:

- `secret` defines the name of the Kubernetes `Secret` to pull from.
- `key` defines the name of the key in the above secret that contains the authToken.

All Gitaly nodes **must** share the same authentication token.

### Deprecated Gitaly settings

| Name                         | Type    | Default | Description |
|:---------------------------- |:-------:|:------- |:----------- |
| `host` *(deprecated)*        | String  |         | The hostname of the Gitaly server to use. This can be omitted in lieu of `serviceName`. If this setting is used, it will override any values of `internal` or `external`. |
| `port` *(deprecated)*        | Integer | `8075`  | The port on which to connect to the Gitaly server. |
| `serviceName` *(deprecated)* | String  |         | The name of the `service` which is operating the Gitaly server. If this is present, and `host` is not, the chart will template the hostname of the service (and current `.Release.Name`) in place of the `host` value. This is convenient when using Gitaly as a part of the overall GitLab chart. |

### TLS settings

Configuring Gitaly to serve via TLS is detailed [in the Gitaly chart's documentation](gitlab/gitaly#running-gitaly-over-tls).

## Configure Praefect settings

The global Praefect settings are located under the `global.praefect` key.

Praefect is disabled by default. When enabled with no extra settings, 3 Gitaly replicas will be created, and the Praefect database will need to be manually created on the default PostgreSQL instance.

### Enable Praefect

To enable Praefect with default settings, set `global.praefect.enabled=true`.

See the [Praefect documentation](https://docs.gitlab.com/ee/administration/gitaly/praefect.html) for details on how to operate a Gitaly cluster using Praefect.

### Global settings for Praefect

```yaml
global:
  praefect:
    enabled: false
    virtualStorages:
    - name: default
      gitalyReplicas: 3
      maxUnavailable: 1
    dbSecret: {}
    psql: {}
```

| Name            | Type    | Default     | Description                                                        |
| ----            | ----    | -------     | -----------                                                        |
| enabled         | Boolean    | false       | Whether or not to enable Praefect                                  |
| virtualStorages | List    | See [multiple virtual storages](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#multiple-virtual-storages) above.  | The list of desired virtual storages (each backed by a Gitaly StatefulSet) |
| dbSecret.secret | String  |             | The name of the secret to use for authenticating with the database |
| dbSecret.key    | String  |             | The name of the key in `dbSecret.secret` to use                    |
| psql.host       | String  |             | The hostname of the database server to use (when using an external database) |
| psql.port       | String  |             | The port number of the database server (when using an external database) |
| psql.user       | String  | `praefect` | The database user to use                                           |
| psql.dbName | String | `praefect` | The name of the database to use

## Configure MinIO settings

The GitLab global MinIO settings are located under the `global.minio` key. For more
details on these settings, see the documentation within the [MinIO chart](minio/index.md).

```yaml
global:
  minio:
    enabled: true
    credentials: {}
```

## Configure appConfig settings

The [Webservice](gitlab/webservice/index.md), [Sidekiq](gitlab/sidekiq/index.md), and
[Gitaly](gitlab/gitaly/index.md) charts share multiple settings, which are configured
with the `global.appConfig` key.

```yaml
global:
  appConfig:
    contentSecurityPolicy:
      enabled: false
      report_only: true
      # directives: {}
    enableUsagePing: true
    enableSeatLink: true
    enableImpersonation: true
    applicationSettingsCacheSeconds: 60
    defaultCanCreateGroup: true
    usernameChangingEnabled: true
    issueClosingPattern:
    defaultTheme:
    defaultProjectsFeatures:
      issues: true
      mergeRequests: true
      wiki: true
      snippets: true
      builds: true
      containerRegistry: true
    webhookTimeout:
    gravatar:
      plainUrl:
      sslUrl:
    extra:
      googleAnalyticsId:
      matomoUrl:
      matomoSiteId:
      matomoDisableCookies:
      oneTrustId:
      googleTagManagerNonceId:
    object_store:
      enabled: false
      proxy_download: true
      storage_options: {}
      connection: {}
    lfs:
      enabled: true
      proxy_download: true
      bucket: git-lfs
      connection: {}
    artifacts:
      enabled: true
      proxy_download: true
      bucket: gitlab-artifacts
      connection: {}
    uploads:
      enabled: true
      proxy_download: true
      bucket: gitlab-uploads
      connection: {}
    packages:
      enabled: true
      proxy_download: true
      bucket: gitlab-packages
      connection: {}
    externalDiffs:
      enabled:
      when:
      proxy_download: true
      bucket: gitlab-mr-diffs
      connection: {}
    terraformState:
      enabled: false
      bucket: gitlab-terraform-state
      connection: {}
    dependencyProxy:
      enabled: false
      bucket: gitlab-dependency-proxy
      connection: {}
    backups:
      bucket: gitlab-backups
    incomingEmail:
      enabled: false
      address: ""
      host: "imap.gmail.com"
      port: 993
      ssl: true
      startTls: false
      user: ""
      password:
        secret:
        key: password
      mailbox: inbox
      idleTimeout: 60
      inboxMethod: "imap"
      clientSecret:
        key: secret
      pollInterval: 60
      deliveryMethod: sidekiq
      authToken: {}

    serviceDeskEmail:
      enabled: false
      address: ""
      host: "imap.gmail.com"
      port: 993
      ssl: true
      startTls: false
      user: ""
      password:
        secret:
        key: password
      mailbox: inbox
      idleTimeout: 60
      inboxMethod: "imap"
      clientSecret:
        key: secret
      pollInterval: 60
      deliveryMethod: sidekiq
      authToken: {}

    pseudonymizer:
      configMap:
      bucket: gitlab-pseudo
      connection: {}
    cron_jobs: {}
    sentry:
      enabled: false
      dsn:
      clientside_dsn:
      environment:
    smartcard:
      enabled: false
      CASecret:
      clientCertificateRequiredHost:
    sidekiq:
      routingRules: []
```

### General application settings

The `appConfig` settings that can be used to tweak the general properties of the Rails
application are described below:

| Name                                | Type    | Default | Description |
|:----------------------------------- |:-------:|:------- |:----------- |
| `contentSecurityPolicy`             | Struct  |         | [See below](#content-security-policy). |
| `enableUsagePing`                   | Boolean | `true`  | A flag to disable the [usage ping support](https://docs.gitlab.com/ee/user/admin_area/settings/usage_statistics.html). |
| `enableSeatLink`                    | Boolean | `true`  | A flag to disable the [seat link support](https://docs.gitlab.com/ee/subscriptions/#seat-link). |
| `enableImpersonation`               |         | `nil`   | A flag to disable [user impersonation by Administrators](https://docs.gitlab.com/ee/api/index.html#disable-impersonation). |
| `applicationSettingsCacheSeconds`   | Integer | 60      | An interval value (in seconds) to invalidate the [application settings cache](https://docs.gitlab.com/ee/administration/application_settings_cache.html). |
| `defaultCanCreateGroup`             | Boolean | `true`  | A flag to decide if users are allowed to create groups. |
| `usernameChangingEnabled`           | Boolean | `true`  | A flag to decide if users are allowed to change their username. |
| `issueClosingPattern`               | String  | (empty) | [Pattern to close issues automatically](https://docs.gitlab.com/ee/administration/issue_closing_pattern.html). |
| `defaultTheme`                      | Integer |         | [Numeric ID of the default theme for the GitLab instance](https://gitlab.com/gitlab-org/gitlab-foss/blob/master/lib/gitlab/themes.rb#L17-27). It takes a number, denoting the ID of the theme. |
| `defaultProjectsFeatures.*feature*` | Boolean | `true`  | [See below](#defaultprojectsfeatures). |
| `webHookTimeout`                    | Integer |         | Waiting time in seconds before a [hook is deemed to have failed](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#webhook-fails-or-multiple-webhook-requests-are-triggered). |

#### Content Security Policy

Setting a Content Security Policy (CSP) can help thwart JavaScript cross-site
scripting (XSS) attacks. See GitLab documentation for configuration details. [Content Security Policy Documentation](https://docs.gitlab.com/omnibus/settings/configuration.html#content-security-policy)

Note that when enabled, the `directives` MUST be configured. Sane example
configuration below:

```yaml
global:
  appConfig:
    contentSecurityPolicy:
      enabled: true
      report_only: false
      directives:
        default_src: "'self'"
        script_src: "'self' 'unsafe-inline' 'unsafe-eval' https://www.recaptcha.net https://apis.google.com"
        frame_ancestors: "'self'"
        frame_src: "'self' https://www.recaptcha.net/ https://content.googleapis.com https://content-compute.googleapis.com https://content-cloudbilling.googleapis.com https://content-cloudresourcemanager.googleapis.com"
        img_src: "* data: blob:"
        style_src: "'self' 'unsafe-inline'"
```

Improperly configuring the CSP rules could prevent GitLab from working properly.
Before rolling out a policy, you may also want to change report_only to true to
test the configuration.

#### defaultProjectsFeatures

Flags to decide if new projects should be created with the respective features by
default. All flags default to `true`.

```yaml
defaultProjectsFeatures:
  issues: true
  mergeRequests: true
  wiki: true
  snippets: true
  builds: true
  containerRegistry: true
```

### Gravatar/Libravatar settings

By default, the charts work with Gravatar avatar service available at gravatar.com.
However, a custom Libravatar service can also be used if needed:

| Name                | Type   | Default | Description |
|:------------------- |:------:|:------- |:----------- |
| `gravatar.plainURL` | String | (empty) | [HTTP URL to Libravatar instance (instead of using gravatar.com)](https://docs.gitlab.com/ee/administration/libravatar.html). |
| `gravatar.sslUrl`   | String | (empty) | [HTTPS URL to Libravatar instance (instead of using gravatar.com)](https://docs.gitlab.com/ee/administration/libravatar.html). |

### Hooking Analytics services to the GitLab instance

Settings to configure Analytics services like Google Analytics and Matomo are defined
under the `extra` key below `appConfig`:

| Name                      | Type   | Default | Description |
|:------------------------- |:------:|:------- |:----------- |
| `extra.googleAnalyticsId` | String | (empty) | Tracking ID for Google Analytics. |
| `extra.matomoSiteId`       | String | (empty) | Matomo Site ID. |
| `extra.matomoUrl`          | String | (empty) | Matomo URL. |
| `extra.matomoDisableCookies`| Boolean | (empty) | Disable Matomo cookies (corresponds to `disableCookies` in the Matomo script) |
| `extra.oneTrustId`         | String | (empty) | OneTrust ID. |
| `extra.googleTagManagerNonceId` | String | (empty) | Google Tag Manager ID. |

### Consolidated object storage

In addition to the following section that describes how to configure individual settings
for object storage, we've added a consolidated object storage configuration to ease the use
of shared configuration for these items. Making use of `object_store`, you can configure a
`connection` once, and it will be used for any and all object storage backed features that
are not individually configured with a `connection` property.

```yaml
  enabled: true
  proxy_download: true
  storage_options:
  connection:
    secret:
    key:
```

| Name             | Type    | Default | Description |
|:---------------- |:-------:|:------- |:----------- |
| `enabled`        | Boolean | `false`  | Enable the use of consolidated object storage. |
| `proxy_download` | Boolean | `true`  | Enable proxy of all downloads via GitLab, in place of direct downloads from the `bucket`. |
| `storage_options`| String  | `{}`    | [See below](#storage_options). |
| `connection`     | String  | `{}`    | [See below](#connection). |

The property structure is shared, and all properties here can be overridden by the individual
items below. The `connection` property structure is identical.

**Notice:** The `bucket`, `enabled`, and `proxy_download` properties are the only properties that must be
configured on a per-item level (`global.appConfig.artifacts.bucket`, ...) if you wish to
deviate from the default values.

When using the `AWS` provider for the [connection](#connection) (which is any
S3 compatible provider such as the included MinIO), GitLab Workhorse can offload
all storage related uploads. This will automatically be enabled for you, when
using this consolidated configuration.

### Specify buckets

Each object type should be stored in different buckets.
By default, GitLab uses these bucket names for each type:

| Object type                  | Bucket Name               |
| ---------------------------- | ------------------------- |
| CI artifacts                 | `gitlab-artifacts`        |
| Git LFS                      | `git-lfs`                 |
| Packages                     | `gitlab-packages`         |
| Uploads                      | `gitlab-uploads`          |
| External merge request diffs | `gitlab-mr-diffs`         |
| Terraform State              | `gitlab-terraform-state`  |
| Dependency Proxy             | `gitlab-dependency-proxy` |
| Pages                        | `gitlab-pages`            |

You can use these defaults or configure the bucket names:

```shell
--set global.appConfig.artifacts.bucket=<BUCKET NAME> \
--set global.appConfig.lfs.bucket=<BUCKET NAME> \
--set global.appConfig.packages.bucket=<BUCKET NAME> \
--set global.appConfig.uploads.bucket=<BUCKET NAME> \
--set global.appConfig.externalDiffs.bucket=<BUCKET NAME> \
--set global.appConfig.terraformState.bucket=<BUCKET NAME> \
--set global.appConfig.dependencyProxy.bucket=<BUCKET NAME>
```

#### storage_options

> Introduced in GitLab 13.4.

The `storage_options` are used to configure [S3 Server Side
Encryption](https://docs.gitlab.com/ee/administration/object_storage.html#server-side-encryption-headers).

Setting a default encryption on an S3 bucket is the easiest way to
enable encryption, but you may want to [set a bucket policy to ensure
only encrypted objects are uploaded](https://aws.amazon.com/premiumsupport/knowledge-center/s3-bucket-store-kms-encrypted-objects/).
To do this, you must configure GitLab to send the proper encryption headers
in the `storage_options` configuration section:

|            Setting                  | Description |
|-------------------------------------|-------------|
| `server_side_encryption`            | Encryption mode (`AES256` or `aws:kms`) |
| `server_side_encryption_kms_key_id` | Amazon Resource Name. Only needed when `aws:kms` is used in `server_side_encryption`. See the [Amazon documentation on using KMS encryption](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingKMSEncryption.html) |

Example:

```yaml
  enabled: true
  proxy_download: true
  connection:
    secret: gitlab-rails-storage
    key: connection
  storage_options:
    server_side_encryption: aws:kms
    server_side_encryption_kms_key_id: arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab
```

### LFS, Artifacts, Uploads, Packages, External MR diffs, and Dependency Proxy

Details on these settings are below. Documentation is not repeated individually,
as they are structurally identical aside from the default value of the `bucket` property.

```yaml
  enabled: true
  proxy_download: true
  bucket:
  connection:
    secret:
    key:
```

| Name             | Type    | Default | Description |
|:---------------- |:-------:|:------- |:----------- |
| `enabled`        | Boolean | Defaults to `true` for LFS, artifacts, uploads, and packages  | Enable the use of these features with object storage. |
| `proxy_download` | Boolean | `true`  | Enable proxy of all downloads via GitLab, in place of direct downloads from the `bucket`. |
| `bucket`         | String  | Various | Name of the bucket to use from object storage provider. Default will be `git-lfs`, `gitlab-artifacts`, `gitlab-uploads`, or `gitlab-packages`, depending on the service. |
| `connection`     | String  | `{}`    | [See below](#connection). |

#### connection

The `connection` property has been transitioned to a Kubernetes Secret. The contents
of this secret should be a YAML formatted file. Defaults to `{}` and will be ignored
if `global.minio.enabled` is `true`.

This property has two sub-keys: `secret` and `key`.

- `secret` is the name of a Kubernetes Secret. This value is required to use external object storage.
- `key` is the name of the key in the secret which houses the YAML block. Defaults to `connection`.

Valid configuration keys can be found in the [GitLab Job Artifacts Administration](https://docs.gitlab.com/ee/administration/job_artifacts.html#s3-compatible-connection-settings)
documentation. This matches to [Fog](https://github.com/fog), and is different between
provider modules.

Examples for [AWS](https://fog.io/storage/#using-amazon-s3-and-fog) and [Google](https://fog.io/storage/#google-cloud-storage)
providers can be found in [`examples/objectstorage`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage).

- [`rails.s3.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.s3.yaml)
- [`rails.gcs.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.gcs.yaml)
- [`rails.azurerm.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.azurerm.yaml)

Once a YAML file containing the contents of the `connection` has been created, use
this file to create the secret in Kubernetes.

```shell
kubectl create secret generic gitlab-rails-storage \
    --from-file=connection=rails.yaml
```

#### when (only for External MR Diffs)

`externalDiffs` setting has an additional key `when` to
[conditionally store specific diffs on object storage](https://docs.gitlab.com/ee/administration/merge_request_diffs.html#alternative-in-database-storage).
This setting is left empty by default in the Charts, for a default value to be
assigned by the Rails code.

### Incoming email settings

The incoming email settings are explained in the [command line options page](../installation/command-line-options.md#incoming-email-configuration).

### KAS settings

#### Custom secret

One can optionally customize the KAS `secret` name as well and `key`, either by
using Helm's `--set variable` option:

```shell
--set global.appConfig.gitlab_kas.secret=custom-secret-name \
--set global.appConfig.gitlab_kas.key=custom-secret-key \
```

or by configuring your `values.yaml`:

```yaml
global:
  appConfig:
    gitlab_kas:
      secret: "custom-secret-name"
      key: "custom-secret-key"
```

If you'd like to customize the secret value, refer to the [secrets documentation](../installation/secrets.md#gitlab-kas-secret).

#### Custom URLs

The URLs used for KAS by the GitLab backend can be customized
using Helm's `--set variable` option:

```shell
--set global.appConfig.gitlab_kas.externalUrl="wss://custom-kas-url.example.com" \
--set global.appConfig.gitlab_kas.internalUrl="grpc://custom-internal-url" \
```

or by configuring your `values.yaml`:

```yaml
global:
  appConfig:
    gitlab_kas:
      externalUrl: "wss://custom-kas-url.example.com"
      internalUrl: "grpc://custom-internal-url"
```

#### External KAS

The GitLab backend can be made aware of an external KAS server (i.e. not
managed by the chart) by explicitly enabling it and configuring the required
URLs. You can do so using Helm's `--set variable` option:

```shell
--set global.appConfig.gitlab_kas.enabled=true \
--set global.appConfig.gitlab_kas.externalUrl="wss://custom-kas-url.example.com" \
--set global.appConfig.gitlab_kas.internalUrl="grpc://custom-internal-url" \
```

or by configuring your `values.yaml`:

```yaml
global:
  appConfig:
    gitlab_kas:
      enabled: true
      externalUrl: "wss://custom-kas-url.example.com"
      internalUrl: "grpc://custom-internal-url"
```

### LDAP

The `ldap.servers` setting allows for the configuration of [LDAP](https://docs.gitlab.com/ee/administration/auth/ldap/)
user authentication. It is presented as a map, which will be translated into the appropriate
LDAP servers configuration in `gitlab.yml`, as with an installation from source.

Configuring passwords can be done by supplying a `secret` which holds the password.
This password will then be injected into the GitLab configuration at runtime.

An example configuration snippet:

```yaml
ldap:
  preventSignin: false
  servers:
    # 'main' is the GitLab 'provider ID' of this LDAP server
    main:
      label: 'LDAP'
      host: '_your_ldap_server'
      port: 636
      uid: 'sAMAccountName'
      bind_dn: 'cn=administrator,cn=Users,dc=domain,dc=net'
      base: 'dc=domain,dc=net'
      password:
        secret: my-ldap-password-secret
        key: the-key-containing-the-password
```

Example `--set` configuration items, when using the global chart:

```shell
--set global.appConfig.ldap.servers.main.label='LDAP' \
--set global.appConfig.ldap.servers.main.host='your_ldap_server' \
--set global.appConfig.ldap.servers.main.port='636' \
--set global.appConfig.ldap.servers.main.uid='sAMAccountName' \
--set global.appConfig.ldap.servers.main.bind_dn='cn=administrator\,cn=Users\,dc=domain\,dc=net' \
--set global.appConfig.ldap.servers.main.base='dc=domain\,dc=net' \
--set global.appConfig.ldap.servers.main.password.secret='my-ldap-password-secret' \
--set global.appConfig.ldap.servers.main.password.key='the-key-containing-the-password'
```

NOTE:
Commas are considered [special characters](https://helm.sh/docs/intro/using_helm/#the-format-and-limitations-of---set)
within Helm `--set` items. Be sure to escape commas in values such as `bind_dn`:
`--set global.appConfig.ldap.servers.main.bind_dn='cn=administrator\,cn=Users\,dc=domain\,dc=net'`.

#### Disable LDAP web sign in

It can be useful to prevent using LDAP credentials through the web UI when an alternative such as SAML is preferred. This allows LDAP to be used for group sync, while also allowing your SAML identity provider to handle additional checks like custom 2FA.

When LDAP web sign in is disabled, users will not see a LDAP tab on the sign in page. This does not disable [using LDAP credentials for Git access.](https://docs.gitlab.com/ee/administration/auth/ldap/#git-password-authentication)

To disable the use of LDAP for web sign-in, set `global.appConfig.ldap.preventSignin: true`.

#### Using a custom CA or self signed LDAP certificates

If the LDAP server uses a custom CA or self-signed certificate, you must:

1. Ensure that the custom CA/Self-Signed certificate is created as a secret in the cluster/namespace:

   ```shell
   kubectl -n gitlab create secret generic my-custom-ca --from-file=my-custom-ca.pem
   ```

1. Then, specify:

   ```shell
   --set global.certificates.customCAs[0].secret=my-custom-ca.pem
   --set global.appConfig.ldap.servers.main.ca_file=/etc/ssl/certs/ca-cert-my-custom-ca.pem
   ```

This will ensure that the CA is mounted in the relevant pods under `/etc/ssl/certs/ca-cert-my-custom-ca.pem` and specifies its use in the LDAP configuration.

### OmniAuth

GitLab can leverage OmniAuth to allow users to sign in using Twitter, GitHub, Google,
and other popular services. Expanded documentation can be found in the [OmniAuth documentation](https://docs.gitlab.com/ee/integration/omniauth.html)
for GitLab.

```yaml
omniauth:
  enabled: false
  autoSignInWithProvider:
  syncProfileFromProvider: []
  syncProfileAttributes: ['email']
  allowSingleSignOn: ['saml']
  blockAutoCreatedUsers: true
  autoLinkLdapUser: false
  autoLinkSamlUser: false
  autoLinkUser: ['saml']
  externalProviders: []
  allowBypassTwoFactor: []
  providers: []
  # - secret: gitlab-google-oauth2
  #   key: provider
```

| Name                      | Type    | Default     | Description |
|:------------------------- |:-------:|:----------- |:----------- |
| `allowBypassTwoFactor`    |         |             | Allows users to log in with the specified providers without two factor authentication. Can be set to `true`, `false`, or an array of providers. See [Bypassing two factor authentication](https://docs.gitlab.com/ee/integration/omniauth.html#bypassing-two-factor-authentication). |
| `allowSingleSignOn`       | Array | `['saml']`     | Enable the automatic creation of accounts when signing in with OmniAuth. Input the [name of the OmniAuth Provider](https://docs.gitlab.com/ee/integration/omniauth.html#supported-providers). |
| `autoLinkLdapUser`        | Boolean | `false`     | Can be used if you have LDAP / ActiveDirectory integration enabled. When enabled, users automatically created through OmniAuth will be linked to their LDAP entry as well. |
| `autoLinkSamlUser`        | Boolean | `false`     | Can be used if you have SAML integration enabled. When enabled, users automatically created through OmniAuth will be linked to their SAML entry as well. |
| `autoLinkUser`            |         |             | Allows users authenticating via an OmniAuth provider to be automatically linked to a current GitLab user if their emails match. Can be set to `true`, `false`, or an array of providers. |
| `autoSignInWithProvider`  |         | `nil`       | Single provider name allowed to automatically sign in. This should match the name of the provider, such as `saml` or `google_oauth2`. |
| `blockAutoCreatedUsers`   | Boolean | `true`      | If `true` auto created users will be blocked by default and will have to be unblocked by an administrator before they are able to sign in. |
| `enabled`                 | Boolean | `false`     | Enable / disable the use of OmniAuth with GitLab. |
| `externalProviders`       |         | `[]`        | You can define which OmniAuth providers you want to be `external`, so that all users **creating accounts, or logging in via these providers** will be unable to access internal projects. You will need to use the full name of the provider, like `google_oauth2` for Google. See [Configure OmniAuth Providers as External](https://docs.gitlab.com/ee/integration/omniauth.html#configure-omniauth-providers-as-external). |
| `providers`               |         | `[]`        | [See below](#providers). |
| `syncProfileAttributes`   |         | `['email']` | List of profile attributes to sync from the provider upon login. See [Keep OmniAuth user profiles up to date](https://docs.gitlab.com/ee/integration/omniauth.html#keep-omniauth-user-profiles-up-to-date) for options. |
| `syncProfileFromProvider` |         | `[]`        | List of provider names that GitLab should automatically sync profile information from. Entries should match the name of the provider, such as `saml` or `google_oauth2`. See [Keep OmniAuth user profiles up to date](https://docs.gitlab.com/ee/integration/omniauth.html#keep-omniauth-user-profiles-up-to-date). |

#### providers

`providers` is presented as an array of maps that are used to populate `gitlab.yml`
as when installed from source. See GitLab documentation for the available selection
of [Supported Providers](https://docs.gitlab.com/ee/integration/omniauth.html#supported-providers).
Defaults to `[]`.

This property has two sub-keys: `secret` and `key`:

- `secret`: *(required)* The name of a Kubernetes `Secret` containing the provider block.
- `key`: *(optional)* The name of the key in the `Secret` containing the provider block.
  Defaults to `provider`

The `Secret` for these entries contains YAML or JSON formatted blocks, as described
in [OmniAuth Providers](https://docs.gitlab.com/ee/integration/omniauth.html). To
create this secret, follow the appropriate instructions for retrieval of these items,
and create a YAML or JSON file.

Example of configuration of Google OAuth2:

```yaml
name: google_oauth2
label: Google
app_id: 'APP ID'
app_secret: 'APP SECRET'
args:
  access_type: offline
  approval_prompt: ''
```

SAML configuration example:

```yaml
name: saml
label: 'SAML'
args:
  assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
  idp_cert_fingerprint: 'xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx'
  idp_sso_target_url: 'https://SAML_IDP/app/xxxxxxxxx/xxxxxxxxx/sso/saml'
  issuer: 'https://gitlab.example.com'
  name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
```

This content can be saved as `provider.yaml`, and then a secret created from it:

```shell
kubectl create secret generic -n NAMESPACE SECRET_NAME --from-file=provider=provider.yaml
```

Once created, the `providers` are enabled by providing the maps in configuration, as
shown below:

```yaml
omniauth:
  providers:
    - secret: gitlab-google-oauth2
    - secret: gitlab-azure-oauth2
    - secret: gitlab-cas3
```

Example configuration `--set` items, when using the global chart:

```shell
--set global.appConfig.omniauth.providers[0].secret=gitlab-google-oauth2 \
```

Due to the complexity of using `--set` arguments, a user may wish to use a YAML snippet,
passed to `helm` with `-f omniauth.yaml`.

### Pseudonymizer settings

Use these settings to configure the [Pseudonymizer service](https://docs.gitlab.com/ee/administration/pseudonymizer.html).

```yaml
global:
  appConfig:
    pseudonymizer:
      configMap:
      bucket: gitlab-pseudo
      connection: {}
```

| Name          | Type    | Default         | Description |
|:------------- |:-------:|:--------------- |:----------- |
| `bucket`      | String  | `gitlab-pseudo` | Name of the bucket to use from the object storage provider. |
| `configMap`   | String  |                 | [See Below](#configmap). |
| `connnection` |         | `{}`            | [See Below](#connection). |

#### configMap

Name of the `configMap` containing a custom manifest file. Defaults to empty.

GitLab ships with a [default manifest file for Pseudonymizer](https://gitlab.com/gitlab-org/gitlab/blob/master/config/pseudonymizer.yml).
Users can provide a custom one as a configMap:

1. First, create a configMap:

   ```shell
   kubectl create configmap <name of the configmap> --from-file=pseudonymizer.yml=<path to pseudonymizer_config.yml>
   ```

   Make sure the key specified in the above command to create configMap is `pseudonymizer.yml`.
   It is used to point the service to the correct location and an incorrect key will cause
   Pseudonymizer to not work.

1. Then, pass the argument `--set global.appConfig.pseudonymizer.configMap=<name of the configmap>`
   to the `helm install` command to instruct GitLab to use this manifest instead of the
   default one.

#### connection

Details of the Kubernetes secret that contains the connection information for the
object storage provider. The contents of this secret should be a YAML formatted file.

Defaults to `{}` and will be ignored if `global.minio.enabled` is `true`.

This property has two sub-keys: `secret` and `key`:

- `secret` is the name of a Kubernetes Secret. This value is required to use external object storage.
- `key` is the name of the key in the secret which houses the YAML block. Defaults to `connection`.

Examples for [AWS (s3)](https://fog.io/storage/#using-amazon-s3-and-fog) and [Google (GCS)](https://fog.io/storage/#google-cloud-storage)
providers can be found in [`examples/objectstorage`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage):

- [`rails.s3.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.s3.yaml)
- [`rails.gcs.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.gcs.yaml)

Once a YAML file containing the contents of the `connection` has been created, create
the secret in Kubernetes:

```shell
kubectl create secret generic gitlab-rails-storage \
    --from-file=connection=rails.yaml
```

### Cron jobs related settings

Sidekiq includes maintenance jobs that can be configured to run on a periodic
basis using cron style schedules. A few examples are included below. See the
sample [`gitlab.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/config/gitlab.yml.example#L346-427)
for more job examples.

These settings are shared between Sidekiq, Webservice (for showing tooltips in UI)
and Toolbox (for debugging purposes) pods.

```yaml
global:
  appConfig:
    cron_jobs:
      stuck_ci_jobs_worker:
        cron: "0 * * * *"
      pipeline_schedule_worker:
        cron: "19 * * * *"
      expire_build_artifacts_worker:
        cron: "*/7 * * * *"
```

### Sentry settings

Use these settings to enable [GitLab error reporting with Sentry](https://docs.gitlab.com/omnibus/settings/configuration.html#error-reporting-and-logging-with-sentry).

```yaml
global:
  appConfig:
    sentry:
      enabled:
      dsn:
      clientside_dsn:
      environment:
```

| Name        | Type    | Default | Description |
|:----------- |:-------:|:------- |:----------- |
| `enabled`        | Boolean | `false`  | Enable or Disable the integration |
| `dsn`            | String  |        | Sentry DSN for backend errors |
| `clientside_dsn` | String  |        | Sentry DSN for front-end errors |
| `environment`    | String  |        | See [Sentry environments](https://docs.sentry.io/product/sentry-basics/environments/) |

### Smartcard Authentication settings

```yaml
global:
  appConfig:
    smartcard:
      enabled: false
      CASecret:
      clientCertificateRequiredHost:
      sanExtensions: false
      requiredForGitAccess: false
```

| Name                            | Type    | Default | Description                                      |
| :------------------------------ | :-----: | :------ | :----------------------------------------------- |
| `enabled`                       | Boolean | `false` | Enable or Disable smartcard authentication       |
| `CASecret`                      | String  |         | Name of the secret containing the CA certificate |
| `clientCertificateRequiredHost` | String  |         | Hostname to use for smartcard authentication. By default, the provided or computed smartcard hostname is used. |
| `sanExtensions`                 | Boolean | `false` | Enable the use of SAN extensions to match users with certificates. |
| `requiredForGitAccess`          | Boolean | `false` | Require browser session with smartcard sign-in for Git access. |

### Sidekiq routing rules settings

GitLab supports routing a job from a worker to a desired queue before it is
scheduled. Sidekiq clients match a job against a configured list of routing
rules. Rules are evaluated from first to last, and as soon as a match for a
given worker is found, the processing for that worker is stopped (first match wins). If
the worker doesn't match any rule, it falls back the queue name generated from
the worker name.

By default, the routing rules are not configured (or denoted with an empty
array), all the jobs are routed to the queue generated from the worker name.

The routing rules list is an ordered array of tuples of query and
corresponding queue:

- The query is following the
  [worker matching query](https://docs.gitlab.com/ee/administration/operations/extra_sidekiq_processes.html#queue-selector) syntax.
- The `<queue_name>` must be a valid Sidekiq queue name. If the queue name
  is `nil`, or an empty string, the worker is routed to the queue generated
  by the name of the worker instead.

The query supports wildcard matching `*`, which matches all workers. As a
result, the wildcard query must stay at the end of the list or the later rules
are ignored:

```yaml
global:
  appConfig:
    sidekiq:
      routingRules:
      - ["resource_boundary=cpu", "cpu_boundary"]
      - ["feature_category=pages", null]
      - ["feature_category=search", "search"]
      - ["feature_category=memory|resource_boundary=memory", "memory-bound"]
      - ["*", "default"]
```

## Configure Rails settings

A large portion of the GitLab suite is based upon Rails. As such, many containers within this project operate with this stack. These settings apply to all of those containers, and provide an easy access method to setting them globally versus individually.

```yaml
global:
  rails:
    bootsnap:
      enabled: true
```

## Configure Workhorse settings

Several components of the GitLab suite speak to the APIs via GitLab Workhorse. This is currently a part of the Webservice chart. These settings are consumed by all charts that need to contact GitLab Workhorse, providing an easy access to set them globally vs individually.

```yaml
global:
  workhorse:
    serviceName: webservice-default
    host: api.example.com
    port: 8181
```

| Name | Type | | Default | Description |
| :-- | :-- | :-- | :-- |
| serviceName | String | `webservice-default` | Name of service to direct internal API traffic to. Do not include the Release name, as it will be templated in. Should match an entry in `gitlab.webservice.deployments`. See [`gitlab/webservice` chart](gitlab/webservice/index.md#deployments-settings) |
| scheme | String | `http` | Scheme of the API endpoint |
| host | String | | Fully qualified hostname or IP address of an API endpoint. Overrides the presence of `serviceName`. |
| port | Integer | `8181` | Port number of associated API server. |

### Bootsnap Cache

Our Rails codebase makes use of [Shopify's Bootsnap](https://github.com/Shopify/bootsnap) Gem. Settings here are used to configure that behavior.

`bootsnap.enabled` controls the activation of this feature. It defaults to `true`.

Testing showed that enabling Bootsnap resulted in overall application performance boost. When a pre-compiled cache is available, some application containers see gains in excess of 33%. At this time, GitLab does not ship this pre-compiled cache with their containers, resulting in a gain of "only" 14%. There is a cost to this gain without the pre-compiled cache present, resulting in an intense spike of small IO at initial startup of each Pod. Due to this, we've exposed a method of disabling the use of Bootsnap in environments where this would be an issue.

When possible, we recommend leaving this enabled.

## Configure GitLab Shell

There are several items for the global configuration of [GitLab Shell](gitlab/gitlab-shell/index.md)
chart.

```yaml
global:
  shell:
    port:
    authToken: {}
    hostKeys: {}
    tcp:
      proxyProtocol: false
```

| Name                  | Type    | Default | Description |
|:--------------------- |:-------:|:------- |:----------- |
| `port`                | Integer | `22`    | See [port](#port) below for specific documentation. |
| `authToken`           |         |         | See [authToken](gitlab/gitlab-shell/index.md#authtoken) in the GitLab Shell chart specific documentation. |
| `hostKeys`            |         |         | See [hostKeys](gitlab/gitlab-shell/index.md#hostkeyssecret) in the GitLab Shell chart specific documentation. |
| `tcp.proxyProtocol`   | Boolean | `false` | See [TCP proxy protocol](#tcp-proxy-protocol) below for specific documentation. |

### Port

You can control the port used by the Ingress to pass SSH traffic, as well as the port used
in SSH URLs provided from GitLab via `global.shell.port`. This is reflected in the
port on which the service listens, as well as the SSH clone URLs provided in project UI.

```yaml
global:
  shell:
    port: 32022
```

You can combine `global.shell.port` and `nginx-ingress.controller.service.type=NodePort`
to set a NodePort for the NGINX controller Service object. Note that if
`nginx-ingress.controller.service.nodePorts.gitlab-shell` is set, it will
override `global.shell.port` when setting the NodePort for NGINX.

```yaml
global:
  shell:
    port: 32022

nginx-ingress:
  controller:
    service:
      type: NodePort
```

### TCP proxy protocol

You can enable handling [proxy protocol](https://www.haproxy.com/blog/haproxy/proxy-protocol/) on the SSH Ingress to properly handle a connection from an upstream proxy that adds the proxy protocol header.
By doing so, this will prevent SSH from receiving the additional headers and not break SSH.

One common environment where one needs to enable handling of proxy protocol is when using AWS with an ELB handling the inbound connections to the cluster. You can consult the [AWS layer 4 loadbalancer example](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/aws/elb-layer4-loadbalancer.yaml) to properly set it up.

```yaml
global:
  shell:
    tcp:
      proxyProtocol: true # default false
```

## Configure GitLab Pages

The global GitLab Pages settings that are used by other charts are documented
under the `global.pages` key.

```yaml
global:
  pages:
    enabled:
    accessControl:
    path:
    host:
    port:
    https:
    externalHttp:
    externalHttps:
    artifactsServer:
    objectStore:
      enabled:
      bucket:
      proxy_download: true
      connection: {}
        secret:
        key:
    localStore:
      enabled: false
      path:
    apiSecret: {}
      secret:
      key:
```

| Name                            | Type      | Default                    | Description |
| :---------------------------    | :-------: | :-------                   | :-----------|
| `enabled`                       | Boolean   | False                      | Decides whether to install GitLab Pages chart in the cluster |
| `accessControl`                 | Boolean   | False                      | Enables GitLab Pages Access Control |
| `path`                          | String    | `/srv/gitlab/shared/pages` | Path where Pages deployment related files to be stored. Note: Unused by default, since object storage is used. |
| `host`                          | String    |                            | Pages root domain. |
| `port`                          | String    |                            | Port to be used to construct Pages URLs in UI. If left unset, default value of 80 or 443 is set based on HTTPS situation of Pages. |
| `https`                         | Boolean   | True                       | Whether GitLab UI should show HTTPS URLs for Pages or not. Has precedence over `global.hosts.pages.https` and `global.hosts.https`. Set to True by default. |
| `externalHttp`                  | List      | `[]`                       | List of IP addresses through which HTTP requests reach Pages daemon. For supporting custom domains. |
| `externalHttps`                 | List      | `[]`                       | List of IP addresses through which HTTPS requests reach Pages daemon. For supporting custom domains. |
| `artifactsServer`               | Boolean   | True                       | Enable viewing artifacts in GitLab Pages.|
| `objectStore.enabled`           | Boolean   | True                       | Enable using object storage for Pages. |
| `objectStore.bucket`            | String    | `gitlab-pages`             | Bucket to be used to store content related to Pages |
| `objectStore.connection.secret` | String    |                            | Secret containing connection details for object storage. |
| `objectStore.connection.key`    | String    |                            | Key within the connection secret where connection details are stored. |
| `localStore.enabled`            | Boolean   | False                      | Enable using local storage for content related to Pages (as opposed to objectStore) |
| `localStore.path`               | String    | `/srv/gitlab/shared/pages` | Path where pages files will be stored; only used if localStore is set to true. |
| `apiSecret.secret`              | String    |                            | Secret containing 32 bit API key in Base64 encoded form. |
| `apiSecret.key`                 | String    |                            | Key within the API key secret where the API key is stored. |

## Configure Webservice

The global Webservice settings (that are used by other charts also) are located
under the `global.webservice` key.

```yaml
global:
  webservice:
    workerTimeout: 60
```

### workerTimeout

Configure the request timeout (in seconds) after which a Webservice worker process
is killed by the Webservice master process. The default value is 60 seconds.

## Custom Certificate Authorities

NOTE:
These settings do not affect charts from outside of this repository, via `requirements.yaml`.

Some users may need to add custom certificate authorities, such as when using internally
issued SSL certificates for TLS services. To provide this functionality, we provide
a mechanism for injecting these custom root certificate authorities into the application via secrets.

```yaml
global:
  certificates:
    customCAs:
      - secret: internal-cas
      - secret: other-custom-cas
```

A user can provide any number of secrets, each containing any number of keys that hold
PEM encoded CA certificates. These are configured as entries under `global.certificates.customCAs`.
All keys within the secret will be mounted, so all keys across all secrets must be unique.
These secrets can be named in any fashion, but they *must not* contain key names that collide.

To create a secret:

```shell
kubectl create secret generic custom-ca --from-file=unique_name=/path/to/cert
```

To configure the secret:

```shell
helm install gitlab gitlab/gitlab \
  --set global.certificates.customCAs[0].secret=custom-ca
```

## Application Resource

GitLab can optionally include an [Application resource](https://github.com/kubernetes-sigs/application),
which can be created to identify the GitLab application within the cluster. Requires the
[Application CRD](https://github.com/kubernetes-sigs/application#installing-the-crd),
version `v1beta1`, to already be deployed to the cluster.

To enable, set `global.application.create` to `true`:

```yaml
global:
  application:
    create: true
```

Some environments, such as Google GKE Marketplace, do not allow the creation
of ClusterRole resources. Set the following values to disable ClusterRole
components in the Application Custom Resource Definition as well as the
relevant charts packaged with Cloud Native GitLab.

```yaml
global:
  application:
    allowClusterRoles: false
nginx:
  controller:
    scope:
      enabled: true
gitlab-runner:
  rbac:
    clusterWideAccess: false
certmanager:
  install: false
```

## Busybox image

By default, GitLab Helm charts use `busybox:latest` for booting up various
initContainers. This is controlled by the following settings

```yaml
global:
  busybox:
    image:
      repository: busybox
      tag: latest
```

Many charts also provide `init.image.repository` and `init.image.tag` settings
locally that can be used to override this global setting for that specific
chart.

## Service Accounts

GitLab Helm charts allow for the pods to run using custom [Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/).
This is configured with the following settings in `global.serviceAccount`:

```yaml
global:
  serviceAccount:
    enabled: false
    create: true
    annotations: {}
    ## Name to be used for serviceAccount, otherwise defaults to chart fullname
    # name:
```

- Setting `global.serviceAccount.enabled` to `true` will create a custom service account for each deployment.
- Setting `global.serviceAccount.create` to `false` will disable automatic service account creation.
- Setting `global.serviceAccount.name` will use that name in the deployment for either auto-generated or manually created service accounts.

## Annotations

Custom annotations can be applied to Deployment, Service, and Ingress objects.

```yaml
global:
  deployment:
    annotations:
      environment: production

  service:
    annotations:
      environment: production

  ingress:
    annotations:
      environment: production
```

## Node Selector

Custom `nodeSelector`s can be applied to all components globally. Any global defaults
can also be overridden on each subchart individually.

```yaml
global:
  nodeSelector:
    disktype: ssd
```

> **Note**: charts that are maintained externally do not respect the `global.nodeSelector`
> at this time and may need to be configured separately based on available chart values.
> This includes Prometheus, cert-manager, Redis, etc.

## Labels

### Common Labels

Labels can be applied to nearly all objects that are created by various objects
by using the configuration `common.labels`. This can be applied under the
`global` key, or under a specific charts' configuration. Example:

```yaml
global:
  common:
    labels:
      environment: production
gitlab:
  gitlab-shell:
    common:
      labels:
        foo: bar
```

With the above example configuration, nearly all components deployed by the Helm
chart will be provided the label set `environment: production`. All components
of the GitLab Shell chart will receive the label set `foo: bar`. Some charts
allow for additional nesting. For example, the Sidekiq and Webservices charts
allow for additional deployments depending on your configuration needs:

```yaml
gitlab:
  sidekiq:
    pods:
      - name: pod-0
        common:
          labels:
            baz: bat
```

In the above example, all components associated with the `pod-0` Sidekiq
deployment will also recieve the label set `baz: bat`. Refer to the Sidekiq and
Webservice charts for additional details.

Some charts that we depend on are excluded from this label configuration. Only
the [GitLab component sub-charts](gitlab/index.md) will receive these
extra labels.

### Pod

Custom labels can be applied to various Deployments and Jobs. These labels are
supplementary to existing or preconfigured labels constructed by this Helm
chart. These supplementary labels will **not** be utilized for `matchSelectors`.

```yaml
global:
  pod:
    labels:
      environment: production
```

### Service

Custom labels can be applied to services. These labels are
supplementary to existing or preconfigured labels constructed by this Helm
chart.

```yaml
global:
  service:
    labels:
      environment: production
```

## Tracing

GitLab Helm charts support tracing, and you can configure it with:

```yaml
global:
  tracing:
    connection:
      string: 'opentracing://jaeger?http_endpoint=http%3A%2F%2Fjaeger.example.com%3A14268%2Fapi%2Ftraces&sampler=const&sampler_param=1'
    urlTemplate: 'http://jaeger-ui.example.com/search?service={{ service }}&tags=%7B"correlation_id"%3A"{{ correlation_id }}"%7D'
```

- `global.tracing.connection.string` is used to configure where tracing spans would be sent. You can read more about that in [GitLab tracing documentation](https://docs.gitlab.com/ee/development/distributed_tracing.html)
- `global.tracing.urlTemplate` is used as a template for tracing info URL rendering in GitLab performance bar.

## extraEnv

`extraEnv` allows you to expose additional environment variables in all containers in the pods
that are deployed via GitLab charts (`charts/gitlab/charts`). Extra environment variables set at
the global level will be merged into those provided at the chart level, with precedence given
to those provided at the chart level.

Below is an example use of `extraEnv`:

```yaml
global:
  extraEnv:
    SOME_KEY: some_value
    SOME_OTHER_KEY: some_other_value
```

## Configure OAuth settings

OAuth integration is configured out-of-the box for services which support it.
The services specified in `global.oauth` are automatically registered as OAuth
client applications in GitLab during deployment. By default this list includes
GitLab Pages, if access control is enabled.

```yaml
global:
  oauth:
    gitlab-pages: {}
    # secret
    # appid
    # appsecret
    # redirectUri
```

| Name           | Type   | Default | Description                                                                                            |
| :---           | :--:   | :------ | :----------                                                                                            |
| `secret`       | String |         | Name of the secret with OAuth credentials for the service.                                             |
| `appIdKey`     | String |         | Key in the secret under which App ID of service is stored. Default value being set is `appid`.         |
| `appSecretKey` | String |         | Key in the secret under which App Secret of service is stored. Default value being set is `appsecret`. |
| `redirectUri`  | String |         | URI to which user should be redirected after successful authorization.                                 |

Check the [secrets documentation](../installation/secrets.md#oauth-integration) for more details on the secret.

## Outgoing email

Outgoing email configuration is available via `global.smtp.*` and `global.email.*`.

```yaml
global:
  email:
    display_name: 'GitLab'
    from: 'gitlab@example.com'
    reply_to: 'noreply@example.com'
  smtp:
    enabled: true
    address: 'smtp.example.com'
    tls: true
    authentication: 'plain'
    user_name: 'example'
    password:
      secret: 'smtp-password'
      key: 'password'
```

More information on the available configuration options is available in the
[outgoing email documentation](../installation/command-line-options.md#outgoing-email-configuration)

More detailed examples can be found in the
[Omnibus SMTP settings documentation](https://docs.gitlab.com/omnibus/settings/smtp.html).

## Platform

The `platform` key is reserved for specific features targeting a specific
platform like GKE or EKS.

## Affinity

Affinity configuration is available via `global.antiAffinity` and `global.affinity`.
Affinity allows you to constrain which nodes your pod is eligible to be scheduled on, based on node labels or labels of pods that are already running on a node. This allow spread pods across the cluster or select specific nodes, ensuring more resilience in case of a failing node.

```yaml
global:
  antiAffinity: soft
  affinity:
    podAntiAffinity:
      topologyKey: "kubernetes.io/hostname"
```

| Name                                   | Type   | Default                   | Description                         |
| :------------------------------------- | :--:   | :------------------------ | :---------------------------------- |
| `antiAffinity`                         | String |  `soft`                   | Pod anti-affinity to apply on pods. |
| `affinity.podAntiAffinity.topologyKey` | String |  `kubernetes.io/hostname` | Pod anti-affinity topology key.     |

- `global.antiAffinity` can take two values:
  - `soft`: Define a `preferredDuringSchedulingIgnoredDuringExecution` anti-affinity where the Kubernetes scheduler will try to enforce the rule but will not guarantee the result.
  - `hard`: Defined a `requiredDuringSchedulingIgnoredDuringExecution` anti-affinity where the rule _must_ be met for a pod to be scheduled onto a node.
- `global.affinity.podAntiAffinity.topologyKey` define a node attribute used two divide them into logical zone. Most common `topologyKey` values are :
  - `kubernetes.io/hostname`
  - `topology.kubernetes.io/zone`
  - `topology.kubernetes.io/region`

Kubernetes references on [Inter-pod affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity)
