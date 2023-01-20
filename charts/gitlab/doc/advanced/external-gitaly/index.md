---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Configure this chart with External Gitaly

This document intends to provide documentation on how to configure this Helm chart with an external Gitaly service.

If you don't have Gitaly configured, for on-premise or deployment to VM,
consider using our [Omnibus GitLab package](external-omnibus-gitaly.md).

NOTE:
External Gitaly _services_ can be provided by Gitaly nodes, or
[Praefect](https://docs.gitlab.com/ee/administration/gitaly/praefect.html) clusters.

## Configure the Chart

Disable the `gitaly` chart and the Gitaly service it provides, and point the other services to the external service.

You need to set the following properties:

- `global.gitaly.enabled`: Set to `false` to disable the included Gitaly chart.
- `global.gitaly.external`: This is an array of [external Gitaly service(s)](../../charts/globals.md#external).
- `global.gitaly.authToken.secret`: The name of the [secret which contains the token for authentication](../../installation/secrets.md#gitaly-secret).
- `global.gitaly.authToken.key`: The key within the secret, which contains the token content.

The external Gitaly services will make use of their own instances of GitLab Shell.
Depending your implementation, you can configure those with the secrets from this
chart, or you can configure this chart's secrets with the content from a predefined
source.

You **may** need to set the following properties:

- `global.shell.authToken.secret`: The name of the [secret which contains secret for GitLab Shell](../../installation/secrets.md#gitlab-shell-secret).
- `global.shell.authToken.key`: The key within the secret, which contains the secret content.

A complete example configuration, with two external services (`external-gitaly.yml`):

```yaml
global:
  gitaly:
    enabled: false
    external:
      - name: default                   # required
        hostname: node1.git.example.com # required
        port: 8075                      # optional, default shown
      - name: praefect                  # required
        hostname: ha.git.example.com    # required
        port: 2305                      # Praefect uses port 2305
        tlsEnabled: false               # optional, overrides gitaly.tls.enabled
    authToken:
      secret: external-gitaly-token     # required
      key: token                        # optional, default shown
    tls:
      enabled: false                    # optional, default shown
```

Example installation using the above configuration file in conjunction other
configuration via `gitlab.yml`:

```shell
helm upgrade --install gitlab gitlab/gitlab  \
  -f gitlab.yml \
  -f external-gitaly.yml
```

## Multiple external Gitaly

If your implementation uses multiple Gitaly nodes external to these charts,
you can define multiple hosts as well. The syntax is slightly different, as
to allow the complexity required.

An [example values file](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/gitaly/values-multiple-external.yaml) is provided, which shows the
appropriate set of configuration. The content of this values file is not
interpreted correctly via `--set` arguments, so should be passed to Helm
with the `-f / --values` flag.

### Connecting to external Gitaly over TLS

If your external [Gitaly server listens over TLS port](https://docs.gitlab.com/ee/administration/gitaly/#enable-tls-support),
you can make your GitLab instance communicate with it over TLS. To do this, you
have to

1. Create a Kubernetes secret containing the certificate of the Gitaly
   server

   ```shell
   kubectl create secret generic gitlab-gitaly-tls-certificate --from-file=gitaly-tls.crt=<path to certificate>
   ```

1. Add the certificate of external Gitaly server to the list of
   [custom Certificate Authorities](../../charts/globals.md#custom-certificate-authorities)
   In the values file, specify the following

   ```yaml
   global:
     certificates:
       customCAs:
         - secret: gitlab-gitaly-tls-certificate
   ```

   or pass it to the `helm upgrade` command using `--set`

   ```shell
   --set global.certificates.customCAs[0].secret=gitlab-gitaly-tls-certificate
   ```

1. To enable TLS for all Gitaly instances, set `global.gitaly.tls.enabled: true`.

   ```yaml
   global:
     gitaly:
       tls:
         enabled: true
   ```

   To enable for instances individually, set `tlsEnabled: true` for that entry.

   ```yaml
   global:
     gitaly:
       external:
         - name: default
           hostname: node1.git.example.com
           tlsEnabled: true
   ```

NOTE:
You can choose any valid secret name and key for this, but make
sure the key is unique across all the secrets specified in `customCAs` to avoid
collision since all keys within the secrets will be mounted. You **do not**
need to provide the key for the certificate, as this is the _client side_.
