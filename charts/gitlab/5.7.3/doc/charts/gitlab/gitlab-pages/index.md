---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the GitLab Pages chart **(FREE SELF)**

The `gitlab-pages` subchart provides a daemon for serving static websites from
GitLab projects.

## Requirements

This chart depends on access to the Workhorse services, either as part of the
complete GitLab chart or provided as an external service reachable from the Kubernetes
cluster this chart is deployed onto.

## Configuration

The `gitlab-pages` chart is configured as follows: [Global
Settings](#global-settings) and [Chart Settings](#chart-settings).

## Global Settings

We share some common global settings among our charts. See the
[Globals Documentation](../../globals.md#configure-gitlab-pages) for details.

## Chart settings

The tables in following two sections contains all the possible chart
configurations that can be supplied to the `helm install` command using the
`--set` flags.

### General settings

| Parameter                                 | Default           | Description                                              |
| ----------------------------------------- | ----------------- | -------------------------------------------------------- |
| `annotations`                             |                   | Pod annotations                                          |
| `common.labels`                           | `{}`              | Supplemental labels that are applied to all objects created by this chart. |
| `deployment.strategy`                     | `{}`              | Allows one to configure the update strategy used by the deployment. When not provided, the cluster default is used. |
| `extraEnv`                                |                   | List of extra environment variables to expose            |
| `image.pullPolicy`                        | `IfNotPresent`    | GitLab image pull policy                                 |
| `image.pullSecrets`                       |                   | Secrets for the image repository                         |
| `image.repository`                        | `registry.gitlab.com/gitlab-org/build/cng/gitlab-exporter` | GitLab Exporter image repository |
| `image.tag`                               |                   | image tag                                                |
| `init.image.repository`                   |                   | initContainer image                                      |
| `init.image.tag`                          |                   | initContainer image tag                                  |
| `metrics.enabled`                         | `true`            | Toggle Prometheus metrics exporter                       |
| `metrics.port`                            | `9235`            | Listen port for the Prometheus metrics exporter          |
| `podLabels`                               |                   | Supplemental Pod labels. Will not be used for selectors. |
| `resources.requests.cpu`                  | `75m`             | GitLab Pages minimum CPU                                 |
| `resources.requests.memory`               | `100M`            | GitLab Pages minimum memory                              |
| `securityContext.fsGroup`                 | `1000`            | Group ID under which the pod should be started           |
| `securityContext.runAsUser`               | `1000`            | User ID under which the pod should be started            |
| `service.externalPort`                    | `8090`            | GitLab Pages exposed port                                |
| `service.internalPort`                    | `8090`            | GitLab Pages internal port                               |
| `service.name`                            | `gitlab-pages`    | GitLab Pages service name                                |
| `service.customDomains.type`              | `LoadBalancer`    | Type of service created for handling custom domains      |
| `service.customDomains.internalHttpsPort` | `8091`            | Port where Pages daemon listens for HTTPS requests       |
| `service.customDomains.internalHttpsPort` | `8091`            | Port where Pages daemon listens for HTTPS requests       |
| `service.customDomains.nodePort.http`     |                   | Node Port to be opened for HTTP connections. Valid only if `service.customDomains.type` is `NodePort` |
| `service.customDomains.nodePort.https`    |                   | Node Port to be opened for HTTPS connections. Valid only if `service.customDomains.type` is `NodePort` |
| `serviceLabels`                           | `{}`              | Supplemental service labels                              |
| `tolerations`                             | `[]`              | Toleration labels for pod assignment                     |

### Pages specific settings

| Parameter                        | Default               | Description                                          |
| -------------------------------- | --------------------- | ---------------------------------------------------- |
| `artifactsServerTimeout`         | `10`                  | Timeout (in seconds) for a proxied request to the artifacts server |
| `artifactsServerUrl`             |                       | API URL to proxy artifact requests to                |
| `domainConfigSource`             | `gitlab`              | Domain configuration source                          |
| `extraVolumeMounts`              |                       | List of extra volumes mounts to add                  |
| `extraVolumes`                   |                       | List of extra volumes to create                      |
| `gitlabCache.cleanup`            | int                   | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings) |
| `gitlabCache.expiry`             | int                   | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings) |
| `gitlabCache.refresh`            | int                   | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings) |
| `gitlabClientHttpTimeout`        |                       | GitLab API HTTP client connection timeout in seconds |
| `gitlabClientJwtExpiry`          |                       | JWT Token expiry time in seconds                     |
| `gitlabRetrieval.interval`       | int                   | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings) |
| `gitlabRetrieval.retries`        | int                   | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings) |
| `gitlabRetrieval.timeout`        | int                   | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings) |
| `gitlabServer`                   |                       | GitLab server FQDN                                   |
| `headers`                        | `[]`                  | Specify any additional http headers that should be sent to the client with each response. Multiple headers can be given as an array, header and value as one string, for example `['my-header: myvalue', 'my-other-header: my-other-value']` |
| `insecureCiphers`                | `false`               | Use default list of cipher suites, may contain insecure ones like 3DES and RC4 |
| `internalGitlabServer`           |                       | Internal GitLab server used for API requests         |
| `logFormat`                      | `json`                | Log output format                                    |
| `logVerbose`                     | `false`               | Verbose logging                                      |
| `maxConnections`                 |                       | Limit on the number of concurrent connections to the HTTP, HTTPS or proxy listeners |
| `maxURILength`                   |                       | Limit the length of URI, 0 for unlimited. |
| `propagateCorrelationId`         |                       | Reuse existing Correlation-ID from the incoming request header `X-Request-ID` if present |
| `redirectHttp`                   | `false`               | Redirect pages from HTTP to HTTPS                    |
| `sentry.enabled`                 | `false`               | Enable Sentry reporting                              |
| `sentry.dsn`                     |                       | The address for sending Sentry crash reporting to    |
| `sentry.environment`             |                       | The environment for Sentry crash reporting           |
| `statusUri`                      |                       | The URL path for a status page                       |
| `tls.minVersion`                 |                       | Specifies the minimum SSL/TLS version                |
| `tls.maxVersion`                 |                       | Specifies the maximum SSL/TLS version                |
| `useHttp2`                       | `true`                | Enable HTTP2 support                                 |
| `useHTTPProxy`                   | `false`               | Use this option when GitLab Pages is behind a Reverse Proxy.    |
| `useProxyV2`                     | `false`               | Force HTTPS request to utilize the PROXYv2 protocol. |
| `zipCache.cleanup`               | int                   | See: [Zip Serving and Cache Configuration](https://docs.gitlab.com/ee/administration/pages/index.html#zip-serving-and-cache-configuration) |
| `zipCache.expiration`            | int                   | See: [Zip Serving and Cache Configuration](https://docs.gitlab.com/ee/administration/pages/index.html#zip-serving-and-cache-configuration) |
| `zipCache.refresh`               | int                   | See: [Zip Serving and Cache Configuration](https://docs.gitlab.com/ee/administration/pages/index.html#zip-serving-and-cache-configuration) |
| `zipOpenTimeout`                 | int                   | See: [Zip Serving and Cache Configuration](https://docs.gitlab.com/ee/administration/pages/index.html#zip-serving-and-cache-configuration) |
| `rateLimitSourceIP`              | int                   | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits). To enable rate-limiting use `extraEnv=["FF_ENFORCE_IP_RATE_LIMITS=true"]` |
| `rateLimitSourceIPBurst`         | int                   | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits) |
| `rateLimitDomain`                | int                   | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits). To enable rate-limiting use `extraEnv=["FF_ENFORCE_DOMAIN_RATE_LIMITS=true"]` |
| `rateLimitDomainBurst`           | int                   | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits) |

### Configuring the `ingress`

This section controls the GitLab Pages Ingress.

| Name                   | Type    | Default | Description |
|:---------------------- |:-------:|:------- |:----------- |
| `apiVersion`           | String  |         | Value to use in the `apiVersion` field. |
| `annotations`          | String  |         | This field is an exact match to the standard `annotations` for [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/). |
| `configureCertmanager` | Boolean | `false` | Toggles Ingress annotation `cert-manager.io/issuer`. The acquisition of a TLS certificate for GitLab Pages via cert-manager is disabled because a wildcard certificate acquisition requires a cert-manager Issuer with a [DNS01 solver](https://cert-manager.io/docs/configuration/acme/dns01/), and the Issuer deployed by this chart only provides a [HTTP01 solver](https://cert-manager.io/docs/configuration/acme/http01/). For more information see the [TLS requirement for GitLab Pages](../../../installation/tls.md). |
| `enabled`              | Boolean |         | Setting that controls whether to create Ingress objects for services that support them. When not set, the `global.ingress.enabled` setting is used. |
| `tls.enabled`          | Boolean |         | When set to `false`, you disable TLS for the Pages subchart. This is mainly useful for cases in which you cannot use TLS termination at `ingress-level`, like when you have a TLS-terminating proxy before the Ingress Controller. |
| `tls.secretName`       | String  |         | The name of the Kubernetes TLS Secret that contains a valid certificate and key for the pages URL. When not set, the `global.ingress.tls.secretName` is used instead. Defaults to not being set. |

## Chart configuration examples

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
  - name: example-volume
    mountPath: /etc/example
```

### Configuring the `networkpolicy`

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

The `gitlab-pages` service requires Ingress connections for port 80 and 443 and
Egress connections to various to default workhorse port 8181. This examples adds
the following network policy:

- All Ingress requests from the network on TCP `0.0.0.0/0` port 80 and 443 are allowed
- All Egress requests to the network on UDP `10.0.0.0/8` port 53 are allowed for DNS
- All Egress requests to the network on TCP `10.0.0.0/8` port 8181 are allowed for Workhorse

_Note the example provided is only an example and may not be complete_

```yaml
networkpolicy:
  enabled: true
  ingress:
    enabled: true
    rules:
      - to:
        - ipBlock:
            cidr: 0.0.0.0/0
        ports:
          - port: 80
            protocol: TCP
          - port: 443
            protocol: TCP
  egress:
    enabled: true
    rules:
      - to:
        - ipBlock:
            cidr: 10.0.0.0/8
        ports:
          - port: 8181
            protocol: TCP
          - port: 53
            protocol: UDP
```

### TLS access to GitLab Pages

To have TLS access to the GitLab Pages feature you must:

1. Create a dedicated wildcard certificate for your GitLab Pages domain in this format:
   `*.pages.<yourdomain>`.

1. Create the secret in Kubernetes:

   ```shell
   kubectl create secret tls tls-star-pages-<mysecret> --cert=<path/to/fullchain.pem> --key=<path/to/privkey.pem>
   ```

1. Configure GitLab Pages to use this secret:

   ```yaml
   gitlab:
     gitlab-pages:
       ingress:
         tls:
           secretName: tls-star-pages-<mysecret>
   ```

1. Create a DNS entry in your DNS provider with the name `*.pages.<yourdomaindomain>`
   pointing to your LoadBalancer.
