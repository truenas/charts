---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Troubleshooting

## UPGRADE FAILED: "$name" has no deployed releases

This error occurs on your second install/upgrade if your initial install failed.

If your initial install completely failed, and GitLab was never operational, you
should first purge the failed install before installing again.

```shell
helm uninstall <release-name>
```

If instead, the initial install command timed out, but GitLab still came up successfully,
you can add the `--force` flag to the `helm upgrade` command to ignore the error
and attempt to update the release.

Otherwise, if you received this error after having previously had successful deploys
of the GitLab chart, then you are encountering a bug. Please open an issue on our
[issue tracker](https://gitlab.com/gitlab-org/charts/gitlab/-/issues), and also check out
[issue #630](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/630) where we recovered our
CI server from this problem.

## Error: this command needs 2 arguments: release name, chart path

An error like this could occur when you run `helm upgrade`
and there are some spaces in the parameters. In the following
example, `Test Username` is the culprit:

```shell
helm upgrade gitlab gitlab/gitlab --timeout 600s --set global.email.display_name=Test Username ...
```

To fix it, pass the parameters in single quotes:

```shell
helm upgrade gitlab gitlab/gitlab --timeout 600s --set global.email.display_name='Test Username' ...
```

## Application containers constantly initializing

If you experience Sidekiq, Webservice, or other Rails based containers in a constant
state of Initializing, you're likely waiting on the `dependencies` container to
pass.

If you check the logs of a given Pod specifically for the `dependencies` container,
you may see the following repeated:

```plaintext
Checking database connection and schema version
WARNING: This version of GitLab depends on gitlab-shell 8.7.1, ...
Database Schema
Current version: 0
Codebase version: 20190301182457
```

This is an indication that the `migrations` Job has not yet completed. The purpose
of this Job is to both ensure that the database is seeded, as well as all
relevant migrations are in place. The application containers are attempting to
wait for the database to be at or above their expected database version. This is
to ensure that the application does not malfunction to the schema not matching
expectations of the codebase.

1. Find the `migrations` Job. `kubectl get job -lapp=migrations`
1. Find the Pod being run by the Job. `kubectl get pod -ljob-name=<job-name>`
1. Examine the output, checking the `STATUS` column.

If the `STATUS` is `Running`, continue. If the `STATUS` is `Completed`, the application containers should start shortly after the next check passes.

Examine the logs from this pod. `kubectl logs <pod-name>`

Any failures during the run of this job should be addressed. These will block
the use of the application until resolved. Possible problems are:

- Unreachable or failed authentication to the configured PostgreSQL database
- Unreachable or failed authentication to the configured Redis services
- Failure to reach a Gitaly instance

## Applying configuration changes

The following command will perform the necessary operations to apply any updates made to `gitlab.yaml`:

```shell
helm upgrade <release name> <chart path> -f gitlab.yaml
```

## Included GitLab Runner failing to register

This can happen when the runner registration token has been changed in GitLab. (This often happens after you have restored a backup)

1. Find the new shared runner token located on the `admin/runners` webpage of your GitLab installation.
1. Find the name of existing runner token Secret stored in Kubernetes

   ```shell
   kubectl get secrets | grep gitlab-runner-secret
   ```

1. Delete the existing secret

   ```shell
   kubectl delete secret <runner-secret-name>
   ```

1. Create the new secret with two keys, (`runner-registration-token` with your shared token, and an empty `runner-token`)

   ```shell
   kubectl create secret generic <runner-secret-name> --from-literal=runner-registration-token=<new-shared-runner-token> --from-literal=runner-token=""
   ```

## Too many redirects

This can happen when you have TLS termination before the NGINX Ingress, and the tls-secrets are specified in the configuration.

1. Update your values to set `global.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect": "false"`

   Via a values file:

   ```yaml
   # values.yaml
   global:
     ingress:
       annotations:
         "nginx.ingress.kubernetes.io/ssl-redirect": "false"
   ```

   Via the Helm CLI:

   ```shell
   helm ... --set-string global.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect"=false
   ```

1. Apply the change.

NOTE:
When using an external service for SSL termination, that service is responsible for redirecting to https (if so desired).

## Upgrades fail with Immutable Field Error

### spec.clusterIP

Prior to the 3.0.0 release of these charts, the `spec.clusterIP` property
[had been populated into several Services](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1710)
despite having no actual value (`""`). This was a bug, and causes problems with Helm 3's three-way
merge of properties.

Once the chart was deployed with Helm 3, there would be _no possible upgrade path_ unless one
collected the `clusterIP` properties from the various Services and populated those into the values
provided to Helm, or the affected services are removed from Kubernetes.

The [3.0.0 release of this chart corrected this error](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1710), but it requires manual correction.

This can be solved by simply removing all of the affected services.

1. Remove all affected services:

   ```shell
   kubectl delete services -lrelease=RELEASE_NAME
   ```

1. Perform an upgrade via Helm.
1. Future upgrades will not face this error.

NOTE:
This will change any dynamic value for the `LoadBalancer` for NGINX Ingress from this chart, if in use.
See [global Ingress settings documentation](../charts/globals.md#configure-ingress-settings) for more
details regarding `externalIP`. You may be required to update DNS records!

### spec.selector

Sidekiq pods did not receive a unique selector prior to chart release
`3.0.0`. [The problems with this were documented in](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/663).

Upgrades to `3.0.0` using Helm will automatically delete the old Sidekiq deployments and create new ones by appending `-v1` to the
name of the Sidekiq `Deployments`,`HPAs`, and `Pods`.

Starting from `5.5.0` Helm will delete old Sidekiq deployments from prior versions and will use `-v2` suffix for `Pods`, `Deployments` and `HPAs`.

If you continue to run into this error on the Sidekiq deployment when installing `3.0.0`, resolve these with the following
steps:

1. Remove Sidekiq services

   ```shell
   kubectl delete deployment --cascade -lrelease=RELEASE_NAME,app=sidekiq
   ```

1. Perform an upgrade via Helm.

### cannot patch "RELEASE-NAME-cert-manager" with kind Deployment

Upgrading from **CertManager** version `0.10` introduced a number of
breaking changes. The old Custom Resource Definitions must be uninstalled
and removed from Helm's tracking and then re-installed.

The Helm chart attempts to do this by default but if you encounter this error
you may need to take manual action.

If this error message was encountered, then upgrading requires one more step
than normal in order to ensure the new Custom Resource Definitions are
actually applied to the deployment.

1. Remove the old **CertManager** Deployment.

    ```shell
    kubectl delete deployments -l app=cert-manager --cascade
    ```

1. Run the upgrade again. This time install the new Custom Resource Definitions

    ```shell
    helm upgrade --install --values - YOUR-RELEASE-NAME gitlab/gitlab < <(helm get values YOUR-RELEASE-NAME)
    ```

### cannot patch `gitlab-kube-state-metrics` with kind Deployment

Upgrading from **Prometheus** version `11.16.9` to `15.0.4` changes the selector labels
used on the [kube-state-metrics Deployment](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics),
which is disabled by default (`prometheus.kubeStateMetrics.enabled=false`).

If this error message is encountered, meaning `prometheus.kubeStateMetrics.enabled=true`, then upgrading
requires [an additional step](https://artifacthub.io/packages/helm/prometheus-community/prometheus#to-15-0):

1. Remove the old **kube-state-metrics** Deployment.

   ```shell
   kubectl delete deployments.apps -l app.kubernetes.io/instance=RELEASE_NAME,app.kubernetes.io/name=kube-state-metrics --cascade=orphan
   ```

1. Perform an upgrade via Helm.

## `ImagePullBackOff`, `Failed to pull image` and `manifest unknown` errors

If you are using [`global.gitlabVersion`](../charts/globals.md#gitlab-version),
start by removing that property.
Check the [version mappings between the chart and GitLab](../index.md#gitlab-version-mappings)
and specify a compatible version of the `gitlab/gitlab` chart in your `helm` command.

## UPGRADE FAILED: "cannot patch ..." after `helm 2to3 convert`

This is a known issue. After migrating a Helm 2 release to Helm 3, the subsequent upgrades may fail.
You can find the full explanation and workaround in [Migrating from Helm v2 to Helm v3](../installation/migration/helm.md#known-issues).

## Restoration failure: `ERROR:  cannot drop view pg_stat_statements because extension pg_stat_statements requires it`

You may face this error when restoring a backup on your Helm chart instance. Use the following steps as a workaround:

1. Inside your `toolbox` pod open the DB console:

   ```shell
   /srv/gitlab/bin/rails dbconsole -p
   ```

1. Drop the extension:

   ```shell
   DROP EXTENSION pg_stat_statements
   ```

1. Perform the restoration process.
1. After the restoration is complete, re-create the extension in the DB console:

   ```shell
   CREATE EXTENSION pg_stat_statements
   ```

If you encounter the same issue with the `pg_buffercache` extension,
follow the same steps above to drop and re-create it.

You can find more details about this error in issue [#2469](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2469).

## Bundled PostgreSQL pod fails to start: `database files are incompatible with server`

The following error message may appear in the bundled PostgreSQL pod after upgrading to a new version of the GitLab Helm chart:

```plaintext
gitlab-postgresql FATAL:  database files are incompatible with server
gitlab-postgresql DETAIL:  The data directory was initialized by PostgreSQL version 11, which is not compatible with this version 12.7.
```

To address this, perform a [Helm rollback](https://helm.sh/docs/helm/helm_rollback/) to the previous
version of the chart and then follow the steps in the [upgrade guide](../installation/upgrade.md) to
upgrade the bundled PostgreSQL version. Once PostgreSQL is properly upgraded, try the GitLab Helm
chart upgrade again.

## Bundled NGINX Ingress pod fails to start: `Failed to watch *v1beta1.Ingress`

The following error message may appear in the bundled NGINX Ingress controller pod if running Kubernetes version 1.22 or later:

```plaintext
Failed to watch *v1beta1.Ingress: failed to list *v1beta1.Ingress: the server could not find the requested resource
```

To address this, ensure the Kubernetes version is 1.21 or older. See
[#2852](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2852) for
more information regarding NGINX Ingress support for Kubernetes 1.22 or later.

## Increased load on `/api/v4/jobs/requests` endpoint

You may face this issue if the option `workhorse.keywatcher` was set to `false` for the deployment servicing `/api/*`.
Use the following steps to verify:

1. Access the container `gitlab-workhorse` in the pod serving `/api/*`:

   ```shell
   kubectl exec -it --container=gitlab-workhorse <gitlab_api_pod> -- /bin/bash
   ```

1. Inspect the file `/srv/gitlab/config/workhorse-config.toml`. The `[redis]` configuration might be missing:

   ```shell
   cat /srv/gitlab/config/workhorse-config.toml | grep '\[redis\]'
   ```

If the `[redis]` configuration is not present, the `workhorse.keywatcher` flag was set to `false` during deployment
thus causing the extra load in the `/api/v4/jobs/requests` endpoint. To fix this, enable the `keywatcher` in the
`webservice` chart:

```yaml
workhorse:
  keywatcher: true
```

## Git over SSH: `the remote end hung up unexpectedly`

Git operations over SSH might fail intermittently with the following error:

```plaintext
fatal: the remote end hung up unexpectedly
fatal: early EOF
fatal: index-pack failed
```

There are a number of potential causes for this error:

- **Network timeouts**:

  Git clients sometimes open a connection and leave it idling, like when compressing objects.
  Settings like `timeout client` in HAProxy might cause these idle connections to be terminated.

  In [GitLab 14.0 (chart version 5.0)](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/2049)
  and later, you can set a keepalive in `sshd`:

  ```yaml
  gitlab:
    gitlab-shell:
      config:
        clientAliveInterval: 15
  ```

- **`gitlab-shell` memory**:

  By default, the chart does not set a limit on GitLab Shell memory.
  If `gitlab.gitlab-shell.resources.limits.memory` is set too low, Git operations over SSH may fail with these errors.

  Run `kubectl describe nodes` to confirm that this is caused by memory limits rather than
  timeouts over the network.

  ```plaintext
  System OOM encountered, victim process: gitlab-shell
  Memory cgroup out of memory: Killed process 3141592 (gitlab-shell)
  ```

## TLS and certificates

If your GitLab instance needs to trust a private TLS certificate authority, GitLab might
fail to handshake with other services like object storage, Elasticsearch, Jira, or Jenkins:

```plaintext
error: certificate verify failed (unable to get local issuer certificate)
```

Partial trust of certificates signed by private certificate authorities can occur if:

- The supplied certificates are not in separate files.
- The certificates init container doesn't perform all the required steps.

Also, GitLab is mostly written in Ruby on Rails and Golang, and each language's
TLS libraries work differently. This difference can result in issues like job logs
failing to render in the GitLab UI but raw job logs downloading without issue.

Additionally, depending on the `proxy_download` configuration, your browser is
redirected to the object storage with no issues if the trust store is correctly configured.
At the same time, TLS handshakes by one or more GitLab components could still fail.

### Certificate trust setup and troubleshooting

As part of troubleshooting certificate issues, be sure to:

- Create secrets for each certificate you need to trust.
- Provide only one certificate per file.

  ```plaintext
  kubectl create secret generic custom-ca --from-file=unique_name=/path/to/cert
  ```

  In this example, the certificate is stored using the key name `unique_name`

If you supply a bundle or a chain, some GitLab components won't work.

Query secrets with `kubectl get secrets` and `kubectl describe secrets/secretname`,
which shows the key name for the certificate under `Data`.

Supply additional certificates to trust using `global.certificates.customCAs`
[in the chart globals](../charts/globals.md#custom-certificate-authorities).

When a pod is deployed, an init container mounts the certificates and sets them up so the GitLab
components can use them. The init container is`registry.gitlab.com/gitlab-org/build/cng/alpine-certificates`.

Additional certificates are mounted into the container at `/usr/local/share/ca-certificates`,
using the secret key name as the certificate filename.

The init container runs `/scripts/bundle-certificates` ([source](https://gitlab.com/gitlab-org/build/CNG-mirror/-/blob/master/alpine-certificates/scripts/bundle-certificates)).
In that script, `update-ca-certificates`:

1. Copies custom certificates from `/usr/local/share/ca-certificates` to `/etc/ssl/certs`.
1. Compiles a bundle `ca-certificates.crt`.
1. Generates hashes for each certificate and creates a symlink using the hash,
   which is required for Rails. Certificate bundles are skipped with a warning:

   ```plaintext
   WARNING: unique_name does not contain exactly one certificate or CRL: skipping
   ```

[Troubleshoot the init container's status and logs](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-init-containers/#getting-details-about-init-containers).
For example, to view the logs for the certificates init container and check for warnings:

```plaintext
kubectl logs gitlab-webservice-default-pod -c certificates
```

### Check on the Rails console

Use the task runner pod to verify if Rails trusts the certificates you supplied.

1. Start a rails console:

   ```shell
   kubectl get pods | grep task-runner
   kubectl exec -it <task-runner-pod-name> -- bash
   /srv/gitlab/bin/rails console
   ```

1. Verify the location Rails checks for certificate authorities:

   ```ruby
   OpenSSL::X509::DEFAULT_CERT_DIR
   ```

1. Execute an HTTPS query in the Rails console:

   ```ruby
   ## Configure a web server to connect to:
   uri = URI.parse("https://myservice.example.com")

   require 'openssl'
   require 'net/http'
   Rails.logger.level = 0
   OpenSSL.debug=1
   http = Net::HTTP.new(uri.host, uri.port)
   http.set_debug_output($stdout)
   http.use_ssl = true

   http.verify_mode = OpenSSL::SSL::VERIFY_PEER
   # http.verify_mode = OpenSSL::SSL::VERIFY_NONE # TLS verification disabled

   response = http.request(Net::HTTP::Get.new(uri.request_uri))
   ```

### Troubleshoot the init container

Run the certificates container using Docker.

1. Set up a directory structure and populate it with your certificates:

   ```shell
   mkdir -p etc/ssl/certs usr/local/share/ca-certificates

     # The secret name is: my-root-ca
     # The key name is: corporate_root

   kubectl get secret my-root-ca -ojsonpath='{.data.corporate_root}' | \
        base64 --decode > usr/local/share/ca-certificates/corporate_root

     # Check the certificate is correct:

   openssl x509 -in usr/local/share/ca-certificates/corporate_root -text -noout
   ```

1. Determine the correct container version:

   ```shell
   kubectl get deployment -lapp=webservice -ojsonpath='{.items[0].spec.template.spec.initContainers[0].image}'
   ```

1. Run container, which performs the preparation of `etc/ssl/certs` content:

   ```shell
   docker run -ti --rm \
        -v $(pwd)/etc/ssl/certs:/etc/ssl/certs \
        -v $(pwd)/usr/local/share/ca-certificates:/usr/local/share/ca-certificates \
        registry.gitlab.com/gitlab-org/build/cng/alpine-certificates:20191127-r2

1. Check your certificates have been correctly built:

   - `etc/ssl/certs/ca-cert-corporate_root.pem` should have been created.
   - There should be a hashed filename, which is a symlink to the certificate itself (such as `etc/ssl/certs/1234abcd.0`).
   - The file and the symbolic link should display with:

     ```shell
     ls -l etc/ssl/certs/ | grep corporate_root
     ```

     For example:

     ```plaintext
     lrwxrwxrwx   1 root root      20 Oct  7 11:34 28746b42.0 -> ca-cert-corporate_root.pem
     -rw-r--r--   1 root root    1948 Oct  7 11:34 ca-cert-corporate_root.pem
     ```
