---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the Praefect chart (alpha) **(FREE SELF)**

WARNING:
The Praefect chart is still under development. The alpha version is not yet suitable for production use. Upgrades may require significant manual intervention.
See our [Praefect GA release Epic](https://gitlab.com/groups/gitlab-org/charts/-/epics/33) for more information.

The Praefect chart is used to manage a [Gitaly cluster](https://docs.gitlab.com/ee/administration/gitaly/praefect.html) inside a GitLab installment deployed with the Helm charts.

## Known limitations and issues

1. The database has to be [manually created](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2310).
1. The cluster size is fixed: [Gitaly Cluster does not currently support autoscaling](https://gitlab.com/gitlab-org/gitaly/-/issues/2997).
1. Using a Praefect instance in the cluster to manage Gitaly instances outside the cluster is [not supported](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2662).
1. Upgrades to version 4.8 of the chart (GitLab 13.8) [will encounter an issue that makes it _appear_ that repository data is lost](../../../installation/upgrade.md#48-repository-data-appears-to-be-lost-upgrading-praefect). Data is not lost, but requires manual intervention.

## Requirements

This chart consumes the Gitaly chart. Settings from `global.gitaly` are used to configure the instances created by this chart. Documentation of these settings can be found in [Gitaly chart documentation](../gitaly/index.md).

*Important*: `global.gitaly.tls` is independent of `global.praefect.tls`. They are configured separately.

By default, this chart will create 3 Gitaly Replicas.

## Configuration

The chart is disabled by default. To enable it as part of a chart deploy set `global.praefect.enabled=true`.

### Replicas

The default number of replicas to deploy is 3. This can be changed by setting `global.praefect.virtualStorages[].gitalyReplicas` with the desired number of replicas. For example:

```yaml
global:
  praefect:
    enabled: true
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
```

### Multiple virtual storages

Multiple virtual storages can be configured (see [Gitaly Cluster](https://docs.gitlab.com/ee/administration/gitaly/praefect.html) documentation). For example:

```yaml
global:
  praefect:
    enabled: true
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
    - name: vs2
      gitalyReplicas: 5
      maxUnavailable: 2
```

This will create two sets of resources for Gitaly. This includes two Gitaly StatefulSets (one per virtual storage).

Administrators can then [configure where new repositories are stored](https://docs.gitlab.com/ee/administration/repository_storage_paths.html#configure-where-new-repositories-are-stored).

### Persistence

It is possible to provide persistence configuration per virtual storage.

```yaml
global:
  praefect:
    enabled: true
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
      persistence:
        enabled: true
        size: 50Gi
        accessMode: ReadWriteOnce
        storageClass: storageclass1
    - name: vs2
      gitalyReplicas: 5
      maxUnavailable: 2
      persistence:
        enabled: true
        size: 100Gi
        accessMode: ReadWriteOnce
        storageClass: storageclass2
```

### Migrating to Praefect

NOTE:
Group-level wikis [cannot be moved using the API](https://docs.gitlab.com/ee/api/project_repository_storage_moves.html#limitations) at this time.

When migrating from standalone Gitaly instances to a Praefect setup, `global.praefect.replaceInternalGitaly` can be set to `false`.
This ensures that the existing Gitaly instances are preserved while the new Praefect-managed Gitaly instances are created.

```yaml
global:
  praefect:
    enabled: true
    replaceInternalGitaly: false
    virtualStorages:
    - name: virtualStorage2
      gitalyReplicas: 5
      maxUnavailable: 2
```

NOTE:
When migrating to Praefect, none of Praefect's virtual storages can be named `default`.
This is because there must be at least one storage named `default` at all times,
therefore the name is already taken by the non-Praefect configuration.

The instructions to [migrate existing repositories to Gitaly Cluster](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#migrate-existing-repositories-to-gitaly-cluster)
can then be followed to move data from the `default` storage to `virtualStorage2`. If additional storages
were defined under `global.gitaly.internal.names`, be sure to migrate repositories from those storages as well.

After the repositories have been migrated to `virtualStorage2`, `replaceInternalGitaly` can be set back to `true` if a storage named
`default` is added in the Praefect configuration.

```yaml
global:
  praefect:
    enabled: true
    replaceInternalGitaly: true
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
    - name: virtualStorage2
      gitalyReplicas: 5
      maxUnavailable: 2
```

The instructions to [migrate existing repositories to Gitaly Cluster](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#migrate-existing-repositories-to-gitaly-cluster)
can be followed again to move data from `virtualStorage2` to the newly-added `default` storage if desired.

Finally, see the [repository storage paths documentation](https://docs.gitlab.com/ee/administration/repository_storage_paths.html#choose-where-new-repositories-are-stored)
to configure where new repositories are stored.

### Creating the database

Praefect uses its own database to track its state. This has to be manually created in order for Praefect to be functional.

NOTE:
These instructions assume you are using the bundled PostgreSQL server. If you are using your own server,
there will be some variation in how you connect.

1. Log into your database instance:

   ```shell
   kubectl exec -it $(kubectl get pods -l app=postgresql -o custom-columns=NAME:.metadata.name --no-headers) -- bash
   ```

   ```shell
   PGPASSWORD=$(cat $POSTGRES_POSTGRES_PASSWORD_FILE) psql -U postgres -d template1
   ```

1. Create the database user:

   ```sql
   CREATE ROLE praefect WITH LOGIN;
   ```

1. Set the database user password.

   By default, the `shared-secrets` Job will generate a secret for you.

   1. Fetch the password:

      ```shell
      kubectl get secret RELEASE_NAME-praefect-dbsecret -o jsonpath="{.data.secret}" | base64 --decode
      ```

   1. Set the password in the `psql` prompt:

      ```sql
      \password praefect
      ```

1. Create the database:

   ```sql
   CREATE DATABASE praefect WITH OWNER praefect;
   ```

### Running Praefect over TLS

Praefect supports communicating with client and Gitaly nodes over TLS. This is
controlled by the settings `global.praefect.tls.enabled` and `global.praefect.tls.secretName`.
To run Praefect over TLS follow these steps:

1. The Helm chart expects a certificate to be provided for communicating over
   TLS with Praefect. This certificate should apply to all the Praefect nodes that
   are present. Hence all hostnames of each of these nodes should be added as a
   Subject Alternate Name (SAN) to the certificate or alternatively, you can use wildcards.

   To know the hostnames to use, check the file `/srv/gitlab/config/gitlab.yml`
   file in the Toolbox Pod and check the various `gitaly_address` fields specified
   under `repositories.storages` key within it.

   ```shell
   kubectl exec -it <Toolbox Pod> -- grep gitaly_address /srv/gitlab/config/gitlab.yml
   ```

NOTE:
A basic script for generating custom signed certificates for internal Praefect Pods
[can be found in this repository](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/generate_certificates.sh).
Users can use or refer that script to generate certificates with proper SAN attributes.

1. Create a TLS Secret using the certificate created.

   ```shell
   kubectl create secret tls <secret name> --cert=praefect.crt --key=praefect.key
   ```

1. Redeploy the Helm chart by passing the additional arguments `--set global.praefect.tls.enabled=true --set global.praefect.tls.secretName=<secret name>`

When running Gitaly over TLS, a secret name must be provided for each virtual storage.

```yaml
global:
  gitaly:
    tls:
      enabled: true
  praefect:
    enabled: true
    tls:
      enabled: true
      secretName: praefect-tls
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
      tlsSecretName: default-tls
    - name: vs2
      gitalyReplicas: 5
      maxUnavailable: 2
      tlsSecretName: vs2-tls
```

### Installation command line options

The table below contains all the possible charts configurations that can be supplied to
the `helm install` command using the `--set` flags.

| Parameter                      | Default                                           | Description                                                                                             |
| ------------------------------ | ------------------------------------------        | ----------------------------------------                                                                |
| common.labels                  | `{}`                                              | Supplemental labels that are applied to all objects created by this chart.                              |
| failover.enabled               | true                                              | Whether Praefect should perform failover on node failure                                                |
| failover.readonlyAfter         | false                                             | Whether the nodes should be in read-only mode after failover                                            |
| autoMigrate                    | true                                              | Automatically run migrations on startup                                                                 |
| electionStrategy               | `sql`                                               | See [election strategy](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#automatic-failover-and-leader-election) |
| image.repository               | `registry.gitlab.com/gitlab-org/build/cng/gitaly` | The default image repository to use. Praefect is bundled as part of the Gitaly image                    |
| podLabels                      | `{}`                                              | Supplemental Pod labels. Will not be used for selectors.                                                |
| service.name                   | `praefect`                                        | The name of the service to create                                                                       |
| service.type                   | ClusterIP                                         | The type of service to create                                                                           |
| service.internalPort           | 8075                                              | The internal port number that the Praefect pod will be listening on                                     |
| service.externalPort           | 8075                                              | The port number the Praefect service should expose in the cluster                                       |
| init.resources                 |                                                   |                                                                                                         |
| init.image                     |                                                   |                                                                                                         |
| logging.level                  |                                                   | Log level                                                                                               |
| logging.format                 | `json`                                            | Log format                                                                                              |
| logging.sentryDsn              |                                                   | Sentry DSN URL - Exceptions from Go server                                                              |
| logging.rubySentryDsn          |                                                   | Sentry DSN URL - Exceptions from `gitaly-ruby`                                                          |
| logging.sentryEnvironment      |                                                   | Sentry environment to be used for logging                                                               |
| metrics.enabled                | true                                              |                                                                                                         |
| metrics.port                   | 9236                                              |                                                                                                         |
| securityContext.runAsUser      | 1000                                              |                                                                                                         |
| securityContext.fsGroup        | 1000                                              |                                                                                                         |
| serviceLabels                  | `{}`                                              | Supplemental service labels                                                                             |
| statefulset.strategy           | `{}`                                              | Allows one to configure the update strategy utilized by the statefulset                                 |
